# frozen_string_literal: true

module Api
  module V1
    class TicketsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_organization_from_subdomain # Use subdomain instead of organization_id
      before_action :set_ticket, only: %i[show update destroy assign_to_user escalate_to_problem]
      before_action :set_creator, only: [:create]
      before_action :validate_params, only: [:index]

      VALID_STATUSES = %w[open assigned escalated closed suspended resolved pending].freeze
      VALID_TICKET_TYPES = %w[Incident Request Problem].freeze # Align with TicketForm

      # GET /api/v1/organizations/:subdomain/tickets
      def index
        @tickets = apply_filters(@organization.tickets)
        @tickets = @tickets.paginate(page: params[:page], per_page: 10) # Keep pagination
        render json: {
          tickets: @tickets.map { |ticket| ticket_attributes(ticket) },
          pagination: {
            current_page: @tickets.current_page,
            total_pages: @tickets.total_pages,
            total_entries: @tickets.total_entries
          }
        }
      end

      # GET /api/v1/organizations/:subdomain/tickets/:id
      def show
        render json: ticket_attributes(@ticket)
      end

      # POST /api/v1/organizations/:subdomain/tickets
      def create
        @ticket = @organization.tickets.new(ticket_params)
        @ticket.creator = @creator
        @ticket.requester = @creator
        @ticket.ticket_number = SecureRandom.hex(5) # Generate ticket number
        @ticket.reported_at = Time.current # Set automatically
        @ticket.status = 'open' # Default status

        if params[:ticket][:team_id].present?
          team = @organization.teams.find_by(id: params[:ticket][:team_id])
          return render json: { error: 'Team not found in this organization' }, status: :unprocessable_entity unless team
          @ticket.team = team
        end

        if @ticket.save
          render json: ticket_attributes(@ticket), status: :created, location: api_v1_organization_ticket_url(@organization.subdomain, @ticket)
        else
          render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/organizations/:subdomain/tickets/:id
      def update
        if params[:ticket][:team_id].present?
          team = @organization.teams.find_by(id: params[:ticket][:team_id])
          return render json: { error: 'Team not found in this organization' }, status: :unprocessable_entity unless team
          @ticket.team = team
        end

        if params[:ticket][:assignee_id].present?
          assignee = @ticket.team&.users&.find_by(id: params[:ticket][:assignee_id])
          return render json: { error: 'Assignee not found in the team' }, status: :unprocessable_entity unless assignee
          @ticket.assignee = assignee
        end

        if @ticket.update(ticket_params)
          render json: ticket_attributes(@ticket)
        else
          render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/organizations/:subdomain/tickets/:id
      def destroy
        @ticket.destroy!
        head :no_content
      end

      # POST /api/v1/organizations/:subdomain/tickets/:id/assign_to_user
      def assign_to_user
        unless current_user.teamlead? && current_user.team == @ticket.team
          return render json: { error: 'You are not authorized to assign this ticket' }, status: :unauthorized
        end

        assignee = @ticket.team.users.find_by(id: params[:user_id])
        unless assignee
          return render json: { error: 'User not found in the team' }, status: :unprocessable_entity
        end

        if @ticket.update(assignee: assignee)
          # Assuming SendTicketAssignmentEmailsJob and Notification are defined
          SendTicketAssignmentEmailsJob.perform_later(@ticket, @ticket.team, assignee) if defined?(SendTicketAssignmentEmailsJob)
          Notification.create!(
            user: assignee,
            organization: @ticket.organization,
            message: "You have been assigned a new ticket: #{@ticket.title}",
            read: false,
            metadata: { ticket_id: @ticket.id }
          )
          render json: ticket_attributes(@ticket), status: :ok
        else
          render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/organizations/:subdomain/tickets/:id/escalate_to_problem
      def escalate_to_problem
        unless current_user.teamlead?
          return render json: { error: 'Only team leads can escalate tickets to problems' }, status: :forbidden
        end
        unless @ticket.ticket_type == 'Incident'
          return render json: { error: 'Only incident tickets can be escalated to problems' }, status: :unprocessable_entity
        end

        problem = Problem.create!(
          description: @ticket.description,
          organization: @ticket.organization,
          team: @ticket.team,
          creator: current_user,
          ticket_id: @ticket.id # Link to original ticket
        )

        @ticket.update!(status: 'escalated') # Update status instead of problem association
        render json: { message: 'Ticket escalated to problem', problem: problem.as_json }, status: :created
      end

      private

      def validate_params
        return if validate_status && validate_ticket_type
        false
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
        scope
      end

      def set_ticket
        @ticket = @organization.tickets.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Ticket not found' }, status: :not_found
      end

      def set_creator
        @creator = current_user
        render json: { error: 'User not authenticated' }, status: :unauthorized unless @creator
      end

      def ticket_params
        params.require(:ticket).permit(
          :title, :description, :ticket_type, :urgency, :priority, :impact,
          :team_id, :caller_name, :caller_surname, :caller_email, :caller_phone,
          :customer, :source
        )
      end

      def ticket_attributes(ticket)
        {
          id: ticket.id,
          title: ticket.title,
          description: ticket.description,
          ticket_type: ticket.ticket_type,
          status: ticket.status,
          urgency: ticket.urgency,
          priority: ticket.priority,
          impact: ticket.impact,
          team_id: ticket.team_id,
          assignee_id: ticket.assignee_id,
          requester_id: ticket.requester_id,
          creator_id: ticket.creator_id,
          ticket_number: ticket.ticket_number,
          reported_at: ticket.reported_at,
          caller_name: ticket.caller_name,
          caller_surname: ticket.caller_surname,
          caller_email: ticket.caller_email,
          caller_phone: ticket.caller_phone,
          customer: ticket.customer,
          source: ticket.source
        }
      end
    end
  end
end