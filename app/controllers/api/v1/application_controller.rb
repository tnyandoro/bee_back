# app/controllers/api/v1/dashboard_controller.rb

module Api
  module V1
    class DashboardController < Api::V1::ApplicationController
      # No need to call set_organization_from_subdomain again — already in ApplicationController
      # No need to call authenticate_user! — already in ApplicationController

      def show
        # Use cached dashboard data (per-tenant, expires every 5 minutes)
        cache_key = "dashboard:v4:org_#{@organization.id}"
        data = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
          build_dashboard_data
        end

        render_success(data, "Dashboard loaded successfully", :ok)
      end

      private

      def build_dashboard_data
        org_id = @organization.id

        # Base scopes (always tenant-scoped)
        tickets = Ticket.where(organization_id: org_id)
        users = User.where(organization_id: org_id)
        problems = Problem.where(organization_id: org_id)

        # === Status Mapping (integer → string) ===
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
        breaching_soon_count = tickets.where(breaching_sla: true).where(status: [0, 1, 2]).count # open, assigned, escalated

        # === Top Assignees (safe join) ===
        top_assignees = tickets
                          .where.not(assignee_id: nil)
                          .joins(:assignee)
                          .group("users.id", "users.name")
                          .limit(5)
                          .order(Arel.sql("COUNT(*) DESC"))
                          .pluck("users.name", "COUNT(*)")
                          .map { |name, count| { name: name, count: count } }

        # === Average Resolution Time (in hours) ===
        avg_resolution_hours = tickets
                                 .where.not(resolved_at: nil)
                                 .select("AVG(EXTRACT(EPOCH FROM (resolved_at - created_at)) / 3600)")
                                 .first&.avg&.round(2) || 0.0

        # === Recent Tickets (last 10) ===
        recent_tickets = tickets
                           .includes(:assignee, :user)
                           .order(created_at: :desc)
                           .limit(10)
                           .select(
                             :id, :title, :status, :priority, :created_at,
                             :assignee_id, :user_id, :sla_breached, :breaching_sla
                           )
                           .map do |t|
          {
            id: t.id,
            title: t.title,
            status: status_labels[t.status] || "Unknown",
            priority: priority_labels[t.priority.to_s] || "Unknown",
            created_at: t.created_at.iso8601,
            assignee: t.assignee&.name || "Unassigned",
            reporter: t.user&.name || "Unknown",
            sla_breached: t.sla_breached,
            breaching_sla: t.breaching_sla
          }
        end

        # === Final Response ===
        {
          organization: {
            name: @organization.name,
            address: @organization.address,
            email: @organization.email,
            web_address: @organization.web_address,
            subdomain: @organization.subdomain,
            logo_url: @organization.logo_url
          },
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
            tenant: @organization.subdomain
          }
        }
      end
    end
  end
end