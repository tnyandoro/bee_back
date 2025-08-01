# app/controllers/api/v1/organizations_controller.rb
module Api
  module V1
    class OrganizationsController < ApplicationController
      before_action :set_organization, only: %i[show update destroy users add_user tickets]
      skip_before_action :authenticate_user!, only: [:validate_subdomain]
      skip_before_action :verify_user_organization, only: [:validate_subdomain]

      def index
        @organizations = Organization.all
        render_success(@organizations)
      end

      def show
        render_success(@organization)
      end

      def create
        organization = Organization.new(organization_params)

        ActiveRecord::Base.transaction do
          if organization.save
            admin = organization.users.new(admin_params.merge(role: 'admin'))

            if admin.save
              NotificationService.notify_user(
                admin,
                organization,
                "Welcome! You have been added as an admin to the organization: #{organization.name}"
              )
              render_success(
                { organization: organization, admin: admin },
                "Organization created successfully",
                :created
              )
            else
              raise ActiveRecord::Rollback, "Failed to create admin user"
            end
          else
            render_error(organization.errors.full_messages, "Failed to create organization")
          end
        end
      rescue => e
        Rails.logger.error "Error creating organization: #{e.message}"
        render_error("Failed to create organization", e.message)
      end

      def update
        if @organization.update(organization_params)
          render_success(@organization, "Organization updated successfully")
        else
          render_error(@organization.errors.full_messages, "Failed to update organization")
        end
      end

      def destroy
        if @organization.destroy
          head :no_content
        else
          render_error(@organization.errors.full_messages, "Failed to delete organization")
        end
      end

      def users
        @users = @organization.users
        render_success(@users, "Users retrieved successfully")
      end

      def add_user
        authorize_add_user!

        user = User.find_by(id: params[:user_id])
        unless user
          return render_error("User not found", status: :not_found)
        end

        if @organization.users.exists?(user.id)
          return render_success({}, "User is already a member of this organization")
        end

        @organization.users << user

        NotificationService.notify_user(
          user,
          @organization,
          "You have been added to the organization: #{@organization.name}"
        )

        render_success(user, "User added successfully", :created)
      rescue => e
        Rails.logger.error "Error adding user to organization: #{e.message}"
        render_error("Failed to add user", e.message)
      end

      def validate_subdomain
        subdomain = params[:subdomain].presence || params.dig(:organization, :subdomain)
        return render_error("Subdomain is missing", status: :bad_request) unless subdomain.present?

        organization = Organization.find_by("LOWER(subdomain) = ?", subdomain.downcase)

        if organization
          render_success({ valid: true, organization: { id: organization.id, name: organization.name } })
        else
          render_success({ valid: false, error: "Invalid subdomain" })
        end
      end

      def tickets
        scope = @organization.tickets

        # Apply user-based visibility
        if current_user.can_view_all_tickets?
          # all tickets
        elsif current_user.can_view_assigned_tickets?
          scope = scope.where(assignee_id: current_user.id)
        else
          scope = scope.where(requester_id: current_user.id)
        end

        scope = apply_filters(scope)

        page = [params[:page].to_i, 1].max
        per_page = [[params[:per_page].to_i, 1].max, 100].min

        tickets = scope.paginate(page: page, per_page: per_page)

        render json: {
          tickets: tickets.map { |t| ticket_attributes(t) },
          pagination: {
            current_page: tickets.current_page,
            total_pages: tickets.total_pages,
            total_entries: tickets.total_entries
          }
        }, status: :ok
      end

      private

      def set_organization
        subdomain = params[:subdomain]
        @organization = Organization.find_by("LOWER(subdomain) = ?", subdomain&.downcase)
        render_error("Organization not found", status: :not_found) unless @organization
      end

      def authorize_add_user!
        unless current_user.role_domain_admin? || current_user.role_sub_domain_admin? || current_user.role_general_manager?
          render_forbidden("You are not authorized to add users to this organization")
        end
      end

      def organization_params
        params.require(:organization).permit(:name, :address, :email, :web_address, :subdomain)
      end

      def admin_params
        params.require(:admin).permit(:name, :email, :password, :password_confirmation)
      end

      def apply_filters(scope)
        scope = scope.where(assignee_id: params[:user_id]) if params[:user_id].present?
        scope = scope.where(status: params[:status]) if params[:status].present?
        scope = scope.where(ticket_type: params[:ticket_type]) if params[:ticket_type].present?
        scope
      end

      def ticket_attributes(ticket)
        {
          id: ticket.id,
          ticket_number: ticket.ticket_number,
          title: ticket.title,
          description: ticket.description,
          ticket_type: ticket.ticket_type,
          status: ticket.status,
          urgency: ticket.urgency,
          priority: ticket.priority_before_type_cast,
          impact: ticket.impact,
          team_id: ticket.team_id,
          assignee_id: ticket.assignee_id,
          requester_id: ticket.requester_id,
          creator_id: ticket.creator_id,
          reported_at: ticket.reported_at&.iso8601,
          caller_name: ticket.caller_name,
          caller_surname: ticket.caller_surname,
          caller_email: ticket.caller_email,
          caller_phone: ticket.caller_phone,
          customer: ticket.customer,
          source: ticket.source,
          category: ticket.category,
          response_due_at: ticket.response_due_at&.iso8601,
          resolution_due_at: ticket.resolution_due_at&.iso8601,
          escalation_level: ticket.escalation_level,
          sla_breached: ticket.sla_breached,
          calculated_priority: ticket.calculated_priority,
          resolved_at: ticket.resolved_at&.iso8601,
          resolution_note: ticket.resolution_note,
          assignee: ticket.assignee ? { id: ticket.assignee.id, name: ticket.assignee.name } : nil,
          creator: ticket.creator ? { id: ticket.creator.id, name: ticket.creator.name } : nil
        }
      end
    end
  end
end