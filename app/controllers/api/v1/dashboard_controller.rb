module Api
  module V1
    class DashboardController < Api::V1::ApiController
      before_action :set_organization

      def show
        Rails.logger.info "📊 Dashboard request for subdomain=#{@organization.subdomain}, org=#{@organization.name} (ID: #{@organization.id})"

        cache_key = "dashboard:v32:org_#{@organization.id}" # Updated version
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
        render_error("Organization not found", status: :not_found) unless @organization
      end

      def build_dashboard_data
        Rails.logger.info "Using DashboardController version v32 (priority fix)"
        org_id = @organization.id

        org_attrs = extract_org_attributes(@organization)

        # Preload queries safely
        tickets = Ticket.where(organization_id: org_id).includes(:assignee, :requester)
        users_count = User.where(organization_id: org_id).count
        problems = Problem.where(organization_id: org_id)
        problems_count = problems.count
        Rails.logger.info "Problems count for org_id=#{org_id}: #{problems_count}, problem IDs: #{problems.pluck(:id).join(', ')}"

        status_counts = compute_status_counts(tickets)
        priority_counts = compute_priority_counts(tickets)
        sla_data = compute_sla_metrics(tickets)
        avg_resolution_hours = compute_avg_resolution_hours(tickets)
        top_assignees = compute_top_assignees(tickets)
        recent_tickets = fetch_recent_tickets(tickets)

        total_tickets = status_counts.values.sum
        resolved_closed = status_counts["resolved"].to_i + status_counts["closed"].to_i

        Rails.logger.info "📊 Dashboard data summary:"
        Rails.logger.info "  - Total tickets: #{total_tickets}"
        Rails.logger.info "  - Status counts: #{status_counts}"
        Rails.logger.info "  - Priority counts: #{priority_counts}"
        Rails.logger.info "  - Top assignees: #{top_assignees}"

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
            high_priority_tickets: priority_counts["p1"].to_i + priority_counts["p2"].to_i,
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
        # Map integer status values to string labels
        status_labels = { 
          0 => "open", 
          1 => "assigned", 
          2 => "escalated", 
          3 => "closed", 
          4 => "suspended", 
          5 => "resolved", 
          6 => "pending" 
        }
        
        # Initialize counts with zero values
        counts = status_labels.values.index_with { 0 }
        invalid_statuses = []

        # Count tickets by status
        tickets.group(:status).count.each do |status, count|
          # Handle both string and integer status values
          status_key = case status
                      when String
                        status.to_i
                      when Integer
                        status
                      else
                        nil
                      end

          if status_key && status_labels.key?(status_key)
            counts[status_labels[status_key]] = count
          else
            invalid_statuses << [status, count]
          end
        end

        if invalid_statuses.any?
          Rails.logger.warn "Invalid ticket statuses found: #{invalid_statuses.map { |s,c| "#{s}:#{c}" }.join(', ')}"
        end

        Rails.logger.info "Status counts: #{counts}"
        counts
      end

      def compute_priority_counts(tickets)
        # Map integer priority values to string labels
        # Priority mapping: 0=p4(low), 1=p3(medium), 2=p2(high), 3=p1(critical)
        priority_labels = { 
          0 => "p4",  # Low
          1 => "p3",  # Medium
          2 => "p2",  # High
          3 => "p1"   # Critical
        }
        
        # Initialize counts with zero values
        counts = priority_labels.values.index_with { 0 }
        invalid_priorities = []

        # Count tickets by priority
        tickets.group(:priority).count.each do |priority, count|
          # Handle both string and integer priority values
          priority_key = case priority
                        when String
                          priority.to_i
                        when Integer
                          priority
                        else
                          nil
                        end

          if priority_key && priority_labels.key?(priority_key)
            counts[priority_labels[priority_key]] = count
          else
            invalid_priorities << [priority, count]
            # Default invalid priorities to p4 (low)
            counts["p4"] += count
          end
        end

        if invalid_priorities.any?
          Rails.logger.warn "Invalid ticket priorities found: #{invalid_priorities.map { |p,c| "#{p}:#{c}" }.join(', ')}"
          # Clean up invalid priorities by setting them to 0 (p4/low)
          tickets.where(priority: invalid_priorities.map(&:first)).update_all(priority: 0)
        end

        Rails.logger.info "Priority counts: #{counts}"
        counts
      end

      def compute_sla_metrics(tickets)
        breached_count = tickets.where(sla_breached: true).count
        breaching_soon_count = if Ticket.column_names.include?("breaching_sla")
                                 tickets.where(breaching_sla: true, status: [0,1,2]).count
                               else
                                 0
                               end
        { breached: breached_count, breaching_soon: breaching_soon_count }
      end

      def compute_avg_resolution_hours(tickets)
        avg_seconds = tickets.where.not(resolved_at: nil)
                            .average("EXTRACT(EPOCH FROM (resolved_at - tickets.created_at))")
        avg_seconds ? (avg_seconds / 3600.0).round(1) : 0.0
      end

      def compute_top_assignees(tickets)
        assignee_data = tickets.joins("INNER JOIN users ON tickets.assignee_id = users.id")
                              .where.not(assignee_id: nil)
                              .group("users.id, users.name")
                              .order("count_all DESC")
                              .limit(5)
                              .count

        # Convert to format expected by frontend: [{name: "User Name", tickets: count}]
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

        Rails.logger.info "Recent tickets sample: #{recent.first(3)}"
        recent
      end

      def compute_status_label(status)
        labels = { 
          0 => "open", 
          1 => "assigned", 
          2 => "escalated", 
          3 => "closed", 
          4 => "suspended", 
          5 => "resolved", 
          6 => "pending" 
        }
        
        status_key = status.is_a?(String) ? status.to_i : status
        labels[status_key] || "unknown"
      end

      def compute_clean_priority_label(priority)
        # Return clean priority labels without "Unknown" wrapper
        labels = { 
          0 => "p4",  # Low
          1 => "p3",  # Medium  
          2 => "p2",  # High
          3 => "p1"   # Critical
        }
        
        priority_key = case priority
                      when String
                        priority.to_i
                      when Integer
                        priority
                      else
                        0 # Default to p4/low
                      end
                      
        labels[priority_key] || "p4" # Default to p4 for unknown priorities
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