module Api
  module V1
    class DashboardController < Api::V1::ApiController
      def show
        return render_error("Organization not found", status: :not_found) unless @organization

        Rails.logger.info "📊 Dashboard request for subdomain=#{params[:subdomain]}, org=#{@organization.name} (ID: #{@organization.id})"

        cache_key = "dashboard:v21:org_#{@organization.id}" # Updated cache key
        data = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
          build_dashboard_data
        rescue => e
          Rails.logger.error "❌ Error in build_dashboard_data: #{e.class}: #{e.message}"
          Rails.logger.error e.backtrace.take(20).join("\n  ")
          raise
        end

        render_success(data, "Dashboard loaded successfully", :ok)
      end

      private

      def build_dashboard_data
        Rails.logger.info "Using DashboardController version v21 with enhanced error handling"
        org_id = @organization.id
        Rails.logger.info "📊 Building dashboard data for org_id=#{org_id}"

        # Store organization attributes
        org_attrs = {
          id: @organization.id,
          name: @organization.name,
          address: @organization.address,
          email: @organization.email,
          web_address: @organization.web_address,
          subdomain: @organization.subdomain,
          logo_url: @organization.logo_url,
          phone_number: @organization.phone_number
        }

        tickets = Ticket.where(organization_id: org_id)
        users = User.where(organization_id: org_id)
        problems = Problem.where(organization_id: org_id)

        # === Status Mapping ===
        status_labels = {
          0 => "open",
          1 => "assigned",
          2 => "escalated",
          3 => "closed",
          4 => "suspended",
          5 => "resolved",
          6 => "pending"
        }

        status_counts_raw = tickets.group(:status).count
        status_counts = status_labels.values.each_with_object({}) { |s, h| h[s] = 0 }
        status_counts_raw.each do |status_int, count|
          key = status_labels[status_int]
          status_counts[key] = count if key
        end

        total_tickets = status_counts.values.sum
        resolved_closed = status_counts["resolved"] + status_counts["closed"]

        # === Priority Mapping ===
        priority_labels = { "0" => "p4", "1" => "p3", "2" => "p2", "3" => "p1" }
        priority_counts_raw = tickets.group(:priority).count.transform_keys(&:to_s)
        priority_data = {}
        priority_labels.each do |key, label|
          priority_data[label] = priority_counts_raw[key].to_i
        end

        # === SLA Metrics ===
        breached_count = tickets.where(sla_breached: true).count

        if Ticket.column_names.include?("breaching_sla")
          breaching_soon_count = tickets.where(breaching_sla: true).where(status: [0, 1, 2]).count
        else
          breaching_soon_count = 0
        end

        # === Average Resolution Time ===
        avg_seconds = tickets
                        .where.not(resolved_at: nil)
                        .average("EXTRACT(EPOCH FROM (resolved_at - created_at))")
        avg_resolution_hours = avg_seconds ? (avg_seconds / 3600.0).round(2) : 0.0

        # === Top Assignees ===
        top_assignees = tickets
                          .joins('INNER JOIN users ON tickets.assignee_id = users.id')
                          .where.not(assignee_id: nil)
                          .group('users.id, users.name')
                          .order('count_all DESC')
                          .limit(5)
                          .count
                          .map { |(user_id, user_name), count| 
                            { name: user_name || "Unknown", count: count } 
                          }

        # === Recent Tickets with robust data handling ===
        Rails.logger.info "Processing recent tickets for org_id=#{org_id}"
        Rails.logger.debug "Fetching tickets with includes(:assignee, :user)"
        recent_tickets = tickets
                          .includes(:assignee, :user)
                          .order(created_at: :desc)
                          .limit(10)
                          .map do |t|
          begin
            Rails.logger.debug "Starting processing for ticket #{t.id}"
            Rails.logger.debug "Ticket #{t.id} raw attributes: #{t.attributes.inspect}"
            Rails.logger.debug "Ticket #{t.id}: assignee_id=#{t.assignee_id.inspect}, requester_id=#{t.requester_id.inspect}"
            Rails.logger.debug "Ticket #{t.id}: assignee=#{t.assignee.inspect}, user=#{t.user.inspect}"

            # Get assignee name safely
            Rails.logger.debug "Processing assignee for ticket #{t.id}"
            assignee_name = if t.assignee_id && !t.assignee
                              Rails.logger.warn "Assignee_id #{t.assignee_id} present but assignee is nil for ticket #{t.id}"
                              "Unassigned"
                            elsif t.assignee.is_a?(String)
                              Rails.logger.warn "Unexpected string assignee for ticket #{t.id}: #{t.assignee.inspect}"
                              t.assignee
                            elsif t.assignee.respond_to?(:name)
                              Rails.logger.debug "Assignee is User object for ticket #{t.id}: #{t.assignee.name}"
                              t.assignee.name.to_s
                            else
                              Rails.logger.warn "Unexpected assignee type for ticket #{t.id}: #{t.assignee&.class || 'nil'}"
                              "Unknown"
                            end

            # Get reporter name safely
            Rails.logger.debug "Processing user for ticket #{t.id}"
            reporter_name = if t.requester_id && !t.user
                              Rails.logger.warn "Requester_id #{t.requester_id} present but user is nil for ticket #{t.id}"
                              "Unknown"
                            elsif t.user.is_a?(String)
                              Rails.logger.warn "Unexpected string user for ticket #{t.id}: #{t.user.inspect}"
                              t.user
                            elsif t.user.respond_to?(:name)
                              Rails.logger.debug "User is User object for ticket #{t.id}: #{t.user.name}"
                              t.user.name.to_s
                            else
                              Rails.logger.warn "Unexpected user type for ticket #{t.id}: #{t.user&.class || 'nil'}"
                              "Unknown"
                            end

            Rails.logger.debug "Building ticket data for ticket #{t.id}"
            {
              id: t.id,
              title: t.title || "Untitled",
              status: status_labels[t.status] || "Unknown",
              priority: priority_labels[t.priority.to_s] || "Unknown",
              created_at: t.created_at&.iso8601 || Time.current.iso8601,
              assignee: assignee_name,
              reporter: reporter_name,
              sla_breached: t.sla_breached || false,
              breaching_sla: t.respond_to?(:breaching_sla) ? t.breaching_sla : false
            }
          rescue => e
            Rails.logger.error "Error processing ticket #{t.id}: #{e.class}: #{e.message}"
            Rails.logger.error e.backtrace.take(5).join("\n")
            nil
          end
        end.compact

        Rails.logger.info "Finished processing recent tickets: #{recent_tickets.count} tickets processed"

        # === Final Response ===
        result = {
          organization: org_attrs,
          stats: {
            total_tickets: total_tickets,
            open_tickets: status_counts["open"],
            assigned_tickets: status_counts["assigned"],
            escalated_tickets: status_counts["escalated"],
            resolved_tickets: status_counts["resolved"],
            closed_tickets: status_counts["closed"],
            total_problems: problems.count,
            total_members: users.count,
            high_priority_tickets: priority_data["p1"] + priority_data["p2"],
            unresolved_tickets: total_tickets - resolved_closed,
            resolution_rate_percent: total_tickets > 0 ? ((resolved_closed.to_f / total_tickets) * 100).round(1) : 0
          },
          charts: {
            tickets_by_status: status_counts,
            tickets_by_priority: priority_data,
            top_assignees: top_assignees
          },
          sla: {
            breached: breached_count,
            breaching_soon: breaching_soon_count,
            avg_resolution_hours: avg_resolution_hours,
            on_time_rate_percent: total_tickets > 0 ? (((total_tickets - breached_count).to_f / total_tickets) * 100).round(1) : 100
          },
          recent_tickets: recent_tickets,
          meta: {
            fetched_at: Time.current.iso8601,
            timezone: Time.current.zone.name,
            tenant: org_attrs[:subdomain]
          }
        }

        Rails.logger.info "✅ Dashboard data built successfully"
        result
      rescue => e
        Rails.logger.error "❌ Error in build_dashboard_data: #{e.class}: #{e.message}"
        Rails.logger.error e.backtrace.take(20).join("\n  ")
        raise
      end
    end
  end
end