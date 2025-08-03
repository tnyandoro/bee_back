module Api
  module V1
    class DashboardController < ApplicationController
      before_action :set_organization

      def show
        tickets = @organization.tickets
        problems = @organization.problems
        users = @organization.users

        # Efficient status and priority counts
        ticket_status_counts = tickets.group(:status).count.transform_keys(&:to_s)
        ticket_priority_counts = tickets.group(:priority).count.transform_keys(&:to_s)
        sla_breached_count = tickets.where(sla_breached: true).count
        breaching_soon_count = tickets.where(breaching_sla: true, status: ['open', 'assigned']).count

        # Ensure all statuses
        statuses = %w[open assigned escalated resolved closed]
        status_counts = statuses.each_with_object({}) { |s, h| h[s] = ticket_status_counts[s].to_i }

        # Priority labels
        priority_labels = { "0" => "Critical", "1" => "High", "2" => "Medium", "3" => "Low" }
        priority_data = {}
        priority_labels.each do |key, label|
          priority_data[label] = ticket_priority_counts[key].to_i
        end

        # Top assignees (limit to top 5)
        top_assignees = tickets
                          .where.not(assignee_id: nil)
                          .group(:assignee_id, 'users.name')
                          .joins(:assignee)
                          .order('count_all DESC')
                          .limit(5)
                          .count
                          .map { |(id_name, count)| { name: id_name.second, count: count } }

        # SLA Metrics
        resolved_tickets = tickets.where.not(resolved_at: nil)
        avg_resolution_hours = resolved_tickets.average(:resolution_time_hours)&.round(1) || 0

        # Recent tickets (last 10 created)
        recent_tickets = tickets
                           .includes(:assignee, :user)
                           .order(created_at: :desc)
                           .limit(10)
                           .map do |t|
          {
            id: t.id,
            title: t.title,
            status: t.status,
            priority: priority_labels[t.priority.to_s] || "Unknown",
            created_at: t.created_at.iso8601,
            assignee: t.assignee&.name,
            reporter: t.user&.name,
            sla_breached: t.sla_breached,
            breaching_sla: t.breaching_sla
          }
        end

        render json: {
          organization: {
            name: @organization.name,
            address: @organization.address,
            email: @organization.email,
            web_address: @organization.web_address,
            subdomain: @organization.subdomain
          },
          stats: {
            total_tickets: tickets.count,
            open_tickets: status_counts['open'],
            assigned_tickets: status_counts['assigned'],
            escalated_tickets: status_counts['escalated'],
            resolved_tickets: status_counts['resolved'],
            closed_tickets: status_counts['closed'],
            total_problems: problems.count,
            total_members: users.count,
            high_priority_tickets: (ticket_priority_counts['0'].to_i + ticket_priority_counts['1'].to_i),
            unresolved_tickets: tickets.where(status: ['open', 'assigned', 'escalated']).count,
            resolution_rate_percent: tickets.count > 0 ? ((status_counts['resolved'] + status_counts['closed']) / tickets.count.to_f * 100).round(1) : 0
          },
          charts: {
            tickets_by_status: status_counts,
            tickets_by_priority: priority_data,
            top_assignees: top_assignees
          },
          sla: {
            breached: sla_breached_count,
            breaching_soon: breaching_soon_count,
            avg_resolution_hours: avg_resolution_hours,
            on_time_rate_percent: tickets.count > 0 ? (((tickets.count - sla_breached_count).to_f / tickets.count) * 100).round(1) : 100
          },
          recent_tickets: recent_tickets,
          meta: {
            fetched_at: Time.current.iso8601,
            timezone: Time.current.zone.name
          }
        }, status: :ok
      end

      private

      def set_organization
        subdomain = params[:subdomain].to_s.strip
        if subdomain.blank?
          render json: { error: "Subdomain is required" }, status: :bad_request
          return
        end

        @organization = Organization.find_by(subdomain: subdomain)

        unless @organization
          render json: { error: "Organization not found" }, status: :not_found
          return
        end

      rescue => e
        Rails.logger.error "DashboardController#set_organization failed for subdomain=#{subdomain}: #{e.class}"
        render json: { error: "Internal server error" }, status: :internal_server_error
      end
    end
  end
end