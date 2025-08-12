module Api
  module V1
    class DashboardController < Api::V1::ApiController
      def show
        return render_error("Organization not found", status: :not_found) unless @organization

        Rails.logger.info "📊 Dashboard request for subdomain=#{params[:subdomain]}, org=#{@organization.name} (ID: #{@organization.id})"

        cache_key = "dashboard:v30:org_#{@organization.id}" # Updated version
        data = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
          build_dashboard_data
        end

        render_success(data, "Dashboard loaded successfully", :ok)
      rescue => e
        Rails.logger.error "❌ Dashboard error: #{e.class} - #{e.message}"
        Rails.logger.error e.backtrace.take(10).join("\n  ")
        render_error("An unexpected error occurred", status: :internal_server_error)
      end

      private

      def build_dashboard_data
        Rails.logger.info "Using DashboardController version v30 (priority validation fix)"
        org_id = @organization.id

        org_attrs = extract_org_attributes(@organization)

        # Bulk preload queries
        tickets = Ticket.where(organization_id: org_id).includes(:assignee, :requester)
        users_count = User.where(organization_id: org_id).count
        problems = Problem.where(organization_id: org_id)
        problems_count = problems.count
        Rails.logger.info "Problems count for org_id=#{org_id}: #{problems_count}, problem IDs: #{problems.pluck(:id).join(', ')}"

        status_counts = compute_status_counts(tickets)
        priority_data = compute_priority_counts(tickets)
        sla_data = compute_sla_metrics(tickets)
        avg_resolution_hours = compute_avg_resolution_hours(tickets)
        top_assignees = compute_top_assignees(tickets)
        recent_tickets = fetch_recent_tickets(tickets)

        total_tickets = status_counts.values.sum
        resolved_closed = status_counts["resolved"].to_i + status_counts["closed"].to_i

        {
          organization: org_attrs,
          stats: {
            total_tickets: total_tickets,
            open_tickets: status_counts["open"],
            assigned_tickets: status_counts["assigned"],
            escalated_tickets: status_counts["escalated"],
            resolved_tickets: status_counts["resolved"],
            closed_tickets: status_counts["closed"],
            total_problems: problems_count,
            total_members: users_count,
            high_priority_tickets: priority_data["p1"].to_i + priority_data["p2"].to_i,
            unresolved_tickets: total_tickets - resolved_closed,
            resolution_rate_percent: total_tickets.positive? ? ((resolved_closed.to_f / total_tickets) * 100).round(1) : 0
          },
          charts: {
            tickets_by_status: status_counts,
            tickets_by_priority: priority_data,
            top_assignees: top_assignees
          },
          sla: sla_data.merge(
            avg_resolution_hours: avg_resolution_hours,
            on_time_rate_percent: total_tickets.positive? ? (((total_tickets - sla_data[:breached]).to_f / total_tickets) * 100).round(1) : 100
          ),
          recent_tickets: recent_tickets,
          meta: {
            fetched_at: Time.current.iso8601,
            timezone: Time.zone.name,
            tenant: org_attrs[:subdomain]
          }
        }
      end

      def extract_org_attributes(org)
        {
          id: org.id,
          name: org.name,
          address: org.address,
          email: org.email,
          web_address: org.web_address,
          subdomain: org.subdomain,
          logo_url: org.logo_url,
          phone_number: org.phone_number
        }
      end

      def compute_status_counts(tickets)
        status_labels = {
          0 => "open",
          1 => "assigned",
          2 => "escalated",
          3 => "closed",
          4 => "suspended",
          5 => "resolved",
          6 => "pending"
        }
        counts = status_labels.values.index_with { 0 }
        invalid_statuses = []

        tickets.group(:status).count.each do |status, count|
          status_key = status.is_a?(String) ? status.to_i : status
          if status_labels.key?(status_key)
            counts[status_labels[status_key]] = count
          else
            invalid_statuses << [status, count]
          end
        end

        if invalid_statuses.any?
          Rails.logger.warn "Invalid ticket statuses found: #{invalid_statuses.map { |s, c| "#{s}: #{c}" }.join(', ')}"
        end

        counts
      end

      def compute_priority_counts(tickets)
        priority_labels = { "0" => "p4", "1" => "p3", "2" => "p2", "3" => "p1" }
        counts = priority_labels.values.index_with { 0 }
        invalid_priorities = []

        tickets.group(:priority).count.each do |priority, count|
          priority_key = priority.to_s
          if priority_labels.values.include?(priority_key)
            counts[priority_key] = count
          else
            invalid_priorities << [priority, count]
          end
        end

        if invalid_priorities.any?
          Rails.logger.warn "Invalid ticket priorities found: #{invalid_priorities.map { |p, c| "#{p}: #{c}" }.join(', ')}"
          # Clean up invalid priorities
          tickets.where(priority: invalid_priorities.map(&:first)).update_all(priority: '0') # Maps to p4
          counts = priority_labels.values.index_with { 0 }
          tickets.group(:priority).count.each do |priority, count|
            counts[priority_labels[priority.to_s]] = count if priority_labels[priority.to_s]
          end
        end

        counts
      end

      def compute_sla_metrics(tickets)
        breached_count = tickets.where(sla_breached: true).count
        breaching_soon_count = if Ticket.column_names.include?("breaching_sla")
                                 tickets.where(breaching_sla: true, status: [0, 1, 2]).count
                               else
                                 0
                               end
        { breached: breached_count, breaching_soon: breaching_soon_count }
      end

      def compute_avg_resolution_hours(tickets)
        avg_seconds = tickets.where.not(resolved_at: nil)
                            .average("EXTRACT(EPOCH FROM (resolved_at - tickets.created_at))")
        avg_seconds ? (avg_seconds / 3600.0).round(2) : 0.0
      end

      def compute_top_assignees(tickets)
        tickets.joins("INNER JOIN users ON tickets.assignee_id = users.id")
               .where.not(assignee_id: nil)
               .group("users.id, users.name")
               .order("count_all DESC")
               .limit(5)
               .count
               .map { |(id, name), count| { name: name || "Unknown", count: count } }
      end

      def fetch_recent_tickets(tickets)
        tickets.order("created_at DESC")
               .limit(10)
               .map do |t|
          {
            id: t.id,
            title: t.title || "Untitled",
            status: compute_status_label(t.status),
            priority: compute_priority_label(t.priority),
            created_at: t.created_at&.iso8601 || Time.current.iso8601,
            assignee: safe_user_name(t.assignee, t.caller_name, t.caller_email) || "Unassigned",
            reporter: safe_user_name(t.requester, t.caller_name, t.caller_email) || "Unknown",
            sla_breached: t.sla_breached || false,
            breaching_sla: t.respond_to?(:breaching_sla) ? t.breaching_sla : false
          }
        end
      end

      def compute_status_label(status)
        status_labels = {
          0 => "open",
          1 => "assigned",
          2 => "escalated",
          3 => "closed",
          4 => "suspended",
          5 => "resolved",
          6 => "pending"
        }
        status_key = status.is_a?(String) ? status.to_i : status
        status_labels[status_key] || "Unknown (#{status})"
      end

      def compute_priority_label(priority)
        priority_labels = { "0" => "p4", "1" => "p3", "2" => "p2", "3" => "p1" }
        priority_labels[priority.to_s] || "Unknown (#{priority})"
      end

      def safe_user_name(user, fallback_name, fallback_email)
        case user
        when User then user.name.to_s
        when String then user
        else fallback_name || fallback_email
        end
      end
    end
  end
end