module Api
  module V1
    class DashboardController < Api::V1::ApiController
      before_action :set_organization

      def show
        Rails.logger.info "📊 Dashboard request for subdomain=#{@organization.subdomain}, org=#{@organization.name} (ID: #{@organization.id})"

        cache_key = "dashboard:v36:org_#{@organization.id}" # Updated for cache busting
        data = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
          build_dashboard_data
        end

        render_success(data, "Dashboard loaded successfully", status: :ok)
      rescue => e
        Rails.logger.error "❌ Dashboard error: #{e.class} - #{e.message}"
        Rails.logger.error e.backtrace.take(10).join("\n  ")
        render_error("An unexpected error occurred", status: :internal_server_error)
      end

      private

      def set_organization
        @organization = Organization.find_by(subdomain: params[:subdomain])
        unless @organization
          Rails.logger.error "Organization not found for subdomain: #{params[:subdomain]}"
          render_error("Organization not found", status: :not_found)
        end
      end

      def build_dashboard_data
        Rails.logger.info "Using DashboardController version v36 (fixed string status/priority handling)"
        org_id = @organization.id

        org_attrs = extract_org_attributes(@organization)

        tickets = Ticket.where(organization_id: org_id).includes(:assignee, :requester)
        users_count = User.where(organization_id: org_id).count
        problems = Problem.where(organization_id: org_id)
        problems_count = problems.count

        Rails.logger.info "Organization ID: #{org_id}"
        Rails.logger.info "Total tickets: #{tickets.count}, Ticket IDs: #{tickets.pluck(:id).join(', ')}"
        Rails.logger.info "Total problems: #{problems_count}, Problem IDs: #{problems.pluck(:id).join(', ')}"
        Rails.logger.info "Total users: #{users_count}"

        null_priority_tickets = tickets.where(priority: nil).count
        null_status_tickets = tickets.where(status: nil).count
        if null_priority_tickets > 0 || null_status_tickets > 0
          Rails.logger.warn "Data inconsistency - Tickets with null priority: #{null_priority_tickets}, null status: #{null_status_tickets}"
          tickets.where(priority: nil).update_all(priority: 'p4')
          tickets.where(status: nil).update_all(status: 'open')
        end

        status_counts = compute_status_counts(tickets)
        priority_counts = compute_priority_counts(tickets)
        sla_data = compute_sla_metrics(tickets)
        avg_resolution_hours = compute_avg_resolution_hours(tickets)
        top_assignees = compute_top_assignees(tickets)
        recent_tickets = fetch_recent_tickets(tickets)

        total_tickets = tickets.count
        resolved_closed = status_counts["resolved"].to_i + status_counts["closed"].to_i

        Rails.logger.info "📊 Dashboard data summary:"
        Rails.logger.info "  - Organization: #{@organization.name} (#{org_id})"
        Rails.logger.info "  - Total tickets: #{total_tickets}"
        Rails.logger.info "  - Status counts: #{status_counts}"
        Rails.logger.info "  - Priority counts: #{priority_counts}"
        Rails.logger.info "  - P1 tickets: #{priority_counts['p1']}"
        Rails.logger.info "  - Total problems: #{problems_count}"
        Rails.logger.info "  - SLA data: #{sla_data}"
        Rails.logger.info "  - Top assignees: #{top_assignees}"

        {
          organization: org_attrs,
          stats: {
            total_tickets: total_tickets,
            open_tickets: status_counts["open"].to_i,
            assigned_tickets: status_counts["assigned"].to_i,
            escalated_tickets: status_counts["escalated"].to_i,
            resolved_tickets: status_counts["resolved"].to_i,
            closed_tickets: status_counts["closed"].to_i,
            total_problems: problems_count,
            total_members: users_count,
            p1_tickets: priority_counts["p1"].to_i,
            unresolved_tickets: total_tickets - resolved_closed,
            resolution_rate_percent: total_tickets.positive? ? ((resolved_closed.to_f / total_tickets) * 100).round(1) : 0
          },
          charts: {
            tickets_by_status: status_counts,
            tickets_by_priority: priority_counts,
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
            tenant: org_attrs[:subdomain],
            organization_id: org_id
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
          'open' => 'open',
          'assigned' => 'assigned',
          'escalated' => 'escalated',
          'closed' => 'closed',
          'suspended' => 'suspended',
          'resolved' => 'resolved',
          'pending' => 'pending'
        }

        counts = status_labels.values.index_with { 0 }
        invalid_statuses = []

        ticket_status_counts = tickets.group(:status).count
        Rails.logger.info "Raw ticket status counts: #{ticket_status_counts}"

        ticket_status_counts.each do |status, count|
          status_key = status.to_s.downcase

          if status_labels.key?(status_key)
            counts[status_labels[status_key]] = count
          else
            invalid_statuses << [status, count]
            counts["open"] += count
          end
        end

        if invalid_statuses.any?
          Rails.logger.warn "Invalid ticket statuses found: #{invalid_statuses.map { |s, c| "#{s}:#{c}" }.join(', ')}"
          tickets.where(status: invalid_statuses.map(&:first)).update_all(status: 'open')
        end

        Rails.logger.info "Final status counts: #{counts}"
        counts
      end

      def compute_priority_counts(tickets)
        priority_labels = {
          'p4' => 'p4',
          'p3' => 'p3',
          'p2' => 'p2',
          'p1' => 'p1'
        }

        counts = priority_labels.values.index_with { 0 }
        invalid_priorities = []

        ticket_priority_counts = tickets.group(:priority).count
        Rails.logger.info "Raw ticket priority counts: #{ticket_priority_counts}"

        ticket_priority_counts.each do |priority, count|
          priority_key = priority.to_s.downcase

          if priority_labels.key?(priority_key)
            counts[priority_labels[priority_key]] = count
          else
            invalid_priorities << [priority, count]
            counts["p4"] += count
          end
        end

        if invalid_priorities.any?
          Rails.logger.warn "Invalid ticket priorities found: #{invalid_priorities.map { |p, c| "#{p}:#{c}" }.join(', ')}"
          tickets.where(priority: invalid_priorities.map(&:first)).update_all(priority: 'p4')
        end

        Rails.logger.info "Final priority counts: #{counts}"
        counts
      end

      def compute_sla_metrics(tickets)
        breached_count = tickets.where(sla_breached: true).count
        breaching_soon_count = if Ticket.column_names.include?("breaching_sla")
                                 tickets.where(breaching_sla: true, status: ['open', 'assigned', 'escalated']).count
                               else
                                 0
                               end
        Rails.logger.info "SLA metrics - Breached: #{breached_count}, Breaching soon: #{breaching_soon_count}"
        { breached: breached_count, breaching_soon: breaching_soon_count }
      end

      def compute_avg_resolution_hours(tickets)
        avg_seconds = tickets.where.not(resolved_at: nil)
                            .average("EXTRACT(EPOCH FROM (resolved_at - tickets.created_at))")
        result = avg_seconds ? (avg_seconds / 3600.0).round(1) : 0.0
        Rails.logger.info "Average resolution hours: #{result}"
        result
      end

      def compute_top_assignees(tickets)
        assignee_data = tickets.joins("INNER JOIN users ON tickets.assignee_id = users.id")
                              .where.not(assignee_id: nil)
                              .where(users: { organization_id: @organization.id })
                              .group("users.id, users.name")
                              .order("count_all DESC")
                              .limit(5)
                              .count

        top_assignees = assignee_data.map do |(user_id, user_name), count|
          {
            name: user_name || "Unknown User",
            tickets: count
          }
        end

        Rails.logger.info "Top assignees: #{top_assignees}"
        top_assignees
      end

      def fetch_recent_tickets(tickets)
        recent = tickets.order("created_at DESC").limit(10).map do |t|
          {
            id: t.id,
            title: t.title || "Untitled",
            status: compute_status_label(t.status),
            priority: compute_clean_priority_label(t.priority),
            created_at: t.created_at&.iso8601 || Time.current.iso8601,
            assignee: safe_user_name(t.assignee, t.caller_name, t.caller_email) || "Unassigned",
            reporter: safe_user_name(t.requester, t.caller_name, t.caller_email) || "Unknown",
            sla_breached: t.sla_breached || false,
            breaching_sla: t.respond_to?(:breaching_sla) ? t.breaching_sla : false
          }
        end

        Rails.logger.info "Recent tickets count: #{recent.length}"
        recent
      end

      def compute_status_label(status)
        labels = {
          'open' => 'open',
          'assigned' => 'assigned',
          'escalated' => 'escalated',
          'closed' => 'closed',
          'suspended' => 'suspended',
          'resolved' => 'resolved',
          'pending' => 'pending'
        }
        status_key = status.to_s.downcase
        labels[status_key] || 'open'
      end

      def compute_clean_priority_label(priority)
        labels = {
          'p4' => 'p4',
          'p3' => 'p3',
          'p2' => 'p2',
          'p1' => 'p1'
        }
        priority_key = priority.to_s.downcase
        labels[priority_key] || 'p4'
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