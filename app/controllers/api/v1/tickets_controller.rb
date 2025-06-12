# frozen_string_literal: true
module Api
  module V1
    class TicketsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_organization_from_subdomain
      before_action :set_ticket, only: %i[show update destroy assign_to_user escalate_to_problem resolve]
      before_action :set_creator, only: [:create]
      before_action :validate_params, only: [:index]

      VALID_STATUSES = %w[open assigned escalated closed suspended resolved pending].freeze
      VALID_TICKET_TYPES = %w[Incident Request Problem].freeze
      VALID_CATEGORIES = %w[Technical Billing Support Hardware Software Other].freeze

      def index
        @tickets = apply_filters(@organization.tickets)
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 10).to_i
        per_page = [per_page, 100].min

        if page < 1 || per_page < 1
          render json: { error: "Invalid pagination parameters" }, status: :unprocessable_entity
          return
        end

        @tickets = @tickets.paginate(page: page, per_page: per_page)

        render json: {
          tickets: @tickets.map { |ticket| ticket_attributes(ticket) },
          pagination: {
            current_page: @tickets.current_page,
            total_pages: @tickets.total_pages,
            total_entries: @tickets.total_entries
          }
        }, status: :ok
      end

      def show
        render json: ticket_attributes(@ticket)
      end

      def create
        unless current_user.can_create_tickets?(ticket_params[:ticket_type])
          return render_forbidden("Unauthorized to create #{ticket_params[:ticket_type]} ticket")
        end

        ticket_params_adjusted = ticket_params_with_enums
        
        @ticket = @organization.tickets.new(ticket_params_adjusted)
        @ticket.creator = current_user
        @ticket.requester = current_user
        @ticket.ticket_number ||= generate_unique_ticket_number(ticket_params_adjusted[:ticket_type])
        @ticket.reported_at ||= Time.current
        @ticket.status = 'open'

        # Handle priority conversion
        if ticket_params_adjusted[:priority].present?
          priority_value = ticket_params_adjusted[:priority].to_i
          @ticket.priority = Ticket.priorities.key([0, [3, priority_value].min].max)
        end

        # Process team and assignee
        begin
          process_team_and_assignee(ticket_params_adjusted)
        rescue ActiveRecord::RecordNotFound => e
          return render json: { error: e.message }, status: :not_found
        end

        # Validate category
        unless VALID_CATEGORIES.include?(ticket_params_adjusted[:category])
          return render json: { 
            error: "Invalid category. Allowed values are: #{VALID_CATEGORIES.join(', ')}" 
          }, status: :unprocessable_entity
        end

        if @ticket.save
          create_initial_comment
          create_notifications
          render json: ticket_attributes(@ticket), status: :created
        else
          render json: { 
            errors: @ticket.errors.full_messages,
            details: @ticket.errors.details
          }, status: :unprocessable_entity
        end
      end

      def update
        unless current_user.can_resolve_tickets?(@ticket.ticket_type) || current_user.can_reassign_tickets? || current_user.can_change_urgency?
          return render_forbidden("Unauthorized to update this ticket")
        end

        ticket_params_adjusted = ticket_params_with_enums
        
        if ticket_params_adjusted[:priority].present?
          unless current_user.can_change_urgency?
            return render_forbidden("Unauthorized to change ticket urgency")
          end
          priority_value = ticket_params_adjusted[:priority].to_i
          ticket_params_adjusted[:priority] = Ticket.priorities.key([0, [3, priority_value].min].max)
        end

        begin
          process_team_and_assignee_for_update(ticket_params_adjusted)
        rescue ActiveRecord::RecordNotFound => e
          return render json: { error: e.message }, status: :not_found
        end

        if ticket_params_adjusted[:category].present? && !VALID_CATEGORIES.include?(ticket_params_adjusted[:category])
          return render json: { 
            error: "Invalid category. Allowed values are: #{VALID_CATEGORIES.join(', ')}" 
          }, status: :unprocessable_entity
        end

        # Handle resolution fields if provided (for fallback PUT request)
        if params[:ticket].present?
          resolution_fields = params[:ticket].slice(
            :status, :resolved_at, :resolution_note, :reason, :resolution_method,
            :cause_code, :resolution_details, :end_customer, :support_center, :total_kilometer
          )
          ticket_params_adjusted.merge!(resolution_fields) if resolution_fields.present?
        end

        if @ticket.update(ticket_params_adjusted)
          if ticket_params_adjusted[:status] == 'resolved' && !@ticket.resolved_at_was
            unless current_user.can_resolve_tickets?(@ticket.ticket_type)
              return render_forbidden("Unauthorized to resolve #{@ticket.ticket_type} ticket")
            end
            @ticket.update!(resolved_at: Time.current)
            create_resolution_comment(ticket_params_adjusted[:resolution_note] || "Resolved by #{current_user.name}")
            create_resolution_notification
          end
          render json: ticket_attributes(@ticket)
        else
          render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        unless current_user.is_admin? || current_user.domain_admin?
          return render_forbidden("Only admins can delete tickets")
        end
        @ticket.destroy!
        head :no_content
      end

      def assign_to_user
        unless current_user.can_reassign_tickets? || (current_user.team_lead? && current_user.team == @ticket.team)
          return render json: { error: 'You are not authorized to assign this ticket' }, status: :forbidden
        end

        assignee = @ticket.team.users.find_by(id: params[:user_id])
        unless assignee
          return render json: { error: 'User not found in the team' }, status: :unprocessable_entity
        end

        if @ticket.update(assignee: assignee, status: 'assigned')
          SendTicketAssignmentEmailsJob.perform_later(@ticket, @ticket.team, assignee) if defined?(SendTicketAssignmentEmailsJob)
          create_assignment_notification(assignee)
          render json: ticket_attributes(@ticket).merge(
            notification: {
              id: @ticket.notifications.last.id,
              message: @ticket.notifications.last.message
            }
          ), status: :ok
        else
          render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def escalate_to_problem
        unless current_user.team_lead? || current_user.super_user? || current_user.department_manager? || current_user.general_manager? || current_user.domain_admin?
          return render json: { error: 'Only team leads or higher can escalate tickets to problems' }, status: :forbidden
        end

        @problem = Problem.new(
          description: @ticket.description,
          organization: @ticket.organization,
          team: @ticket.team,
          creator: current_user,
          ticket: @ticket
        )

        if @problem.save
          @ticket.update!(status: 'escalated')
          create_escalation_notification if @ticket.assignee
          render json: { message: 'Ticket escalated to problem', problem: @problem.as_json }, status: :created
        else
          render json: { errors: @problem.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def resolve
        unless current_user.can_resolve_tickets?(@ticket.ticket_type)
          return render json: { error: "You are not authorized to resolve this #{@ticket.ticket_type} ticket" }, status: :forbidden
        end

        if @ticket.resolved? || @ticket.closed?
          return render json: { error: 'Ticket is already resolved or closed' }, status: :unprocessable_entity
        end

        resolution_params_adjusted = resolve_params
        resolution_params_adjusted[:status] = 'resolved'
        resolution_params_adjusted[:resolved_at] = Time.current

        begin
          ActiveRecord::Base.transaction do
            @ticket.update!(resolution_params_adjusted)
            create_resolution_comment(resolution_params_adjusted[:resolution_note] || "Resolved by #{current_user.name}")
            create_resolution_notification
          end
          render json: ticket_attributes(@ticket), status: :ok
        rescue ActiveRecord::RecordInvalid => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end

      private

      def create_notifications
        notification = Notification.create!(
          user: @ticket.requester,
          organization: @ticket.organization,
          message: "New ticket created: #{@ticket.title} (#{@ticket.ticket_number})",
          notifiable: @ticket,
          read: false
        )
        NotificationMailer.notify_user(notification).deliver_later
        if @ticket.assignee
          notification = create_assignment_notification(@ticket.assignee)
          NotificationMailer.notify_user(notification).deliver_later
          SendTicketAssignmentEmailsJob.perform_later(@ticket, @ticket.team, @ticket.assignee) if defined?(SendTicketAssignmentEmailsJob)
        end
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
          reason: ticket.reason,
          resolution_method: ticket.resolution_method,
          cause_code: ticket.cause_code,
          resolution_details: ticket.resolution_details,
          end_customer: ticket.end_customer,
          support_center: ticket.support_center,
          total_kilometer: ticket.total_kilometer,
          assignee: ticket.assignee ? { id: ticket.assignee.id, name: ticket.assignee.name } : nil,
          creator: ticket.creator ? { id: ticket.creator.id, name: ticket.creator.name } : nil,
          requester: ticket.requester ? { id: ticket.requester.id, name: ticket.requester.name } : nil,
          notifications: ticket.notifications.map do |notification|
            {
              id: notification.id,
              message: notification.message,
              read: notification.read,
              created_at: notification.created_at.iso8601
            }
          end
        }
      end

      def ticket_params
        params.require(:ticket).permit(
          :title, :description, :ticket_type, :urgency, :priority, :impact,
          :team_id, :caller_name, :caller_surname, :caller_email, :caller_phone,
          :customer, :source, :category, :assignee_id, :ticket_number, :reported_at,
          :creator_id, :requester_id,
          :status, :resolved_at, :resolution_note, :reason, :resolution_method,
          :cause_code, :resolution_details, :end_customer, :support_center, :total_kilometer
        )
      end

      def resolve_params
        params.require(:ticket).permit(
          :resolution_note, :reason, :resolution_method, :cause_code,
          :resolution_details, :end_customer, :support_center, :total_kilometer
        )
      end

      def set_creator
        @creator = current_user
        render json: { error: 'User not authenticated' }, status: :unauthorized unless @creator
      end

      def set_organization_from_subdomain
        subdomain = params[:organization_subdomain].presence || request.subdomain.presence || 'default'
        @organization = Organization.find_by!(subdomain: subdomain)
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Organization not found for this subdomain' }, status: :not_found
      end

      def validate_params
        return unless validate_status && validate_ticket_type
        true
      end

      def validate_status
        return true unless params[:status].present?
        return true if VALID_STATUSES.include?(params[:status])
        render json: { error: "Invalid status. Allowed values are: #{VALID_STATUSES.join(', ')}" }, status: :unprocessable_entity
        false
      end

      def validate_ticket_type
        return true unless params[:ticket_type].present?
        return true if VALID_TICKET_TYPES.include?(params[:ticket_type])
        render json: { error: "Invalid ticket type. Allowed values are: #{VALID_TICKET_TYPES.join(', ')}" }, status: :unprocessable_entity
        false
      end

      def apply_filters(scope)
        scope = scope.where(assignee_id: params[:user_id]) if params[:user_id].present?
        scope = scope.where(status: params[:status]) if params[:status].present?
        scope = scope.where(ticket_type: params[:ticket_type]) if params[:ticket_type].present?

        # Restrict ticket visibility based on role
        unless current_user.general_manager? || current_user.admin? || current_user.domain_admin?
          scope = scope.where(assignee_id: current_user.id)
                       .or(scope.where(team_id: current_user.team_id))
                       .or(scope.where(department_id: current_user.department_id))
        end

        scope
      end

      def set_ticket
        @ticket = @organization.tickets.find_by!(ticket_number: params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Ticket not found' }, status: :not_found
      end

      def ticket_params_with_enums
        permitted_params = ticket_params.dup
        
        if permitted_params[:urgency].present?
          urgency_value = permitted_params[:urgency].downcase
          permitted_params[:urgency] = Ticket.urgencies[urgency_value]
          unless permitted_params[:urgency]
            raise ArgumentError, "Invalid urgency: #{urgency_value}. Allowed values are: #{Ticket.urgencies.keys.join(', ')}"
          end
        end
        
        if permitted_params[:impact].present?
          impact_value = permitted_params[:impact].downcase
          permitted_params[:impact] = Ticket.impacts[impact_value]
          unless permitted_params[:impact]
            raise ArgumentError, "Invalid impact: #{impact_value}. Allowed values are: #{Ticket.impacts.keys.join(', ')}"
          end
        end
        
        permitted_params
      end

      def generate_unique_ticket_number(ticket_type = 'Incident')
        prefix = case ticket_type
                 when 'Incident' then 'INC'
                 when 'Request' then 'REQ'
                 when 'Problem' then 'PRB'
                 else 'TKT'
                 end

        loop do
          number = "#{prefix}#{SecureRandom.alphanumeric(8).upcase}"
          break number unless Ticket.exists?(ticket_number: number)
        end
      end

      def process_team_and_assignee(params)
        if params[:team_id].present?
          team = @organization.teams.find_by(id: params[:team_id])
          unless team
            raise ActiveRecord::RecordNotFound, 'Team not found in this organization'
          end
          @ticket.team = team

          if params[:assignee_id].present?
            unless current_user.can_reassign_tickets? || (current_user.team_lead? && current_user.team == team)
              raise ArgumentError, 'Unauthorized to assign this ticket'
            end
            assignee = @organization.users.find_by(id: params[:assignee_id])
            unless assignee
              raise ActiveRecord::RecordNotFound, "User #{params[:assignee_id]} not found in organization"
            end
            
            unless team.users.exists?(id: assignee.id)
              raise ActiveRecord::RecordNotFound, "User #{params[:assignee_id]} not found in team #{team.id}"
            end
            
            @ticket.assignee = assignee
            @ticket.status = 'assigned'
          end
        end
      end

      def process_team_and_assignee_for_update(params)
        if params[:team_id].present?
          team = @organization.teams.find_by(id: params[:team_id])
          unless team
            raise ActiveRecord::RecordNotFound, 'Team not found in this organization'
          end
          @ticket.team = team

          if params[:assignee_id].present?
            unless current_user.can_reassign_tickets? || (current_user.team_lead? && current_user.team == team)
              raise ArgumentError, 'Unauthorized to assign this ticket'
            end
            assignee = @organization.users.find_by(id: params[:assignee_id])
            unless assignee
              raise ActiveRecord::RecordNotFound, "User #{params[:assignee_id]} not found in organization"
            end
            
            unless team.users.exists?(id: assignee.id)
              raise ActiveRecord::RecordNotFound, "User #{params[:assignee_id]} not found in team #{team.id}"
            end
            
            @ticket.assignee = assignee
            @ticket.status = 'assigned'
          end
        end
      end

      def create_initial_comment
        @ticket.comments.create!(
          content: "Ticket created by #{@creator.name}",
          user: @creator
        )
      end

      def create_assignment_notification(assignee)
        Notification.create!(
          user: assignee,
          organization: @ticket.organization,
          message: "You have been assigned a new ticket: #{@ticket.title} (#{@ticket.ticket_number})",
          read: false,
          notifiable: @ticket
        )
      end

      def create_escalation_notification
        Notification.create!(
          user: @ticket.assignee,
          organization: @ticket.organization,
          message: "Ticket #{@ticket.ticket_number} has been escalated to a problem",
          read: false,
          notifiable: @problem
        )
      end

      def create_resolution_comment(resolution_note)
        @ticket.comments.create!(
          content: "Ticket resolved: #{resolution_note}",
          user: current_user
        )
      end

      def create_resolution_notification
        if @ticket.assignee && @ticket.assignee != current_user && @ticket.assignee != @ticket.requester
          notification = Notification.create!(
            user: @ticket.assignee,
            organization: @ticket.organization,
            message: "Ticket resolved by #{current_user.name}: #{@ticket.title} (#{@ticket.ticket_number})",
            read: false,
            notifiable: @ticket
          )
          NotificationMailer.notify_user(notification).deliver_later
        end
      end
    end
  end
end