module Api
  module V1
    class DashboardController < Api::V1::ApiController
      def show
        return render_error("Organization not found", status: :not_found) unless @organization

        Rails.logger.info "📊 Dashboard request for subdomain=#{params[:subdomain]}, org=#{@organization.name} (ID: #{@organization.id})"

        cache_key = "dashboard:v17:org_#{@organization.id}"
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
          3 => "on_hold",
          4 => "in_progress",
          5 => "waiting_for_customer",
          6 => "resolved",
          7 => "closed"
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
        priority_labels = { "0" => "Critical", "1" => "High", "2" => "Medium", "3" => "Low" }
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

        # === Recent Tickets with safer data access ===
        recent_tickets = tickets
                          .includes(:assignee, :user)
                          .order(created_at: :desc)
                          .limit(10)
                          .map do |t|
          begin
            # Get assignee name safely
            assignee_name = if t.assignee.nil?
                              "Unassigned"
                            elsif t.assignee.respond_to?(:name)
                              t.assignee.name.to_s
                            else
                              t.assignee.to_s
                            end

            # Get reporter name safely
            reporter_name = if t.user.nil?
                              "Unknown"
                            elsif t.user.respond_to?(:name)
                              t.user.name.to_s
                            else
                              t.user.to_s
                            end

            {
              id: t.id,
              title: t.title,
              status: status_labels[t.status] || "Unknown",
              priority: priority_labels[t.priority.to_s] || "Unknown",
              created_at: t.created_at.iso8601,
              assignee: assignee_name,
              reporter: reporter_name,
              sla_breached: t.sla_breached,
              breaching_sla: t.respond_to?(:breaching_sla) ? t.breaching_sla : false
            }
          rescue => e
            Rails.logger.error "Error processing ticket #{t.id}: #{e.message}"
            Rails.logger.error e.backtrace.take(5).join("\n")
            nil
          end
        end.compact

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
            high_priority_tickets: priority_data["Critical"] + priority_data["High"],
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