# frozen_string_literal: true
module Api
  module V1
    class TicketsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_organization_from_subdomain
      before_action :set_ticket, only: %i[show update destroy assign_to_user escalate_to_problem]
      before_action :set_creator, only: [:create]
      before_action :validate_params, only: [:index]

      VALID_STATUSES = %w[open assigned escalated closed suspended resolved pending].freeze
      VALID_TICKET_TYPES = %w[Incident Request Problem].freeze
      VALID_CATEGORIES = %w[Technical Billing Support Hardware Software Other].freeze

      def index
        @tickets = apply_filters(@organization.tickets)
        @tickets = @tickets.paginate(page: params[:page], per_page: 10)
        render json: {
          tickets: @tickets.map { |ticket| ticket_attributes(ticket) },
          pagination: {
            current_page: @tickets.current_page,
            total_pages: @tickets.total_pages,
            total_entries: @tickets.total_entries
          }
        }
      end

      def show
        render json: ticket_attributes(@ticket)
      end

      def create
        ticket_params_adjusted = ticket_params_with_enums
        # Clamp priority to valid range (0-3)
        if ticket_params_adjusted[:priority].present?
          priority_value = ticket_params_adjusted[:priority].to_i
          ticket_params_adjusted[:priority] = [0, [3, priority_value].min].max # Ensures 0-3 (p4-p1)
        end

        @ticket = @organization.tickets.new(ticket_params_adjusted)
        @ticket.creator = @creator
        @ticket.requester = @creator
        @ticket.user_id = @creator.id
        @ticket.ticket_number = SecureRandom.hex(5)
        @ticket.reported_at = Time.current
        @ticket.status = 'open'

        if ticket_params_adjusted[:team_id].present?
          team = @organization.teams.find_by(id: ticket_params_adjusted[:team_id])
          unless team
            render json: { error: 'Team not found in this organization' }, status: :unprocessable_entity
            return
          end
          @ticket.team = team

          if ticket_params_adjusted[:assignee_id].present?
            assignee = team.users.find_by(id: ticket_params_adjusted[:assignee_id])
            unless assignee
              render json: { error: 'Assignee not found in the selected team' }, status: :unprocessable_entity
              return
            end
            @ticket.assignee = assignee
            @ticket.status = 'assigned'
          end
        end

        unless VALID_CATEGORIES.include?(ticket_params_adjusted[:category])
          render json: { error: "Invalid category. Allowed values are: #{VALID_CATEGORIES.join(', ')}" }, status: :unprocessable_entity
          return
        end

        if @ticket.save
          render json: ticket_attributes(@ticket), status: :created,
                 location: api_v1_organization_ticket_url(@organization.subdomain, @ticket)
        else
          render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        ticket_params_adjusted = ticket_params_with_enums
        # Clamp priority to valid range (0-3)
        if ticket_params_adjusted[:priority].present?
          priority_value = ticket_params_adjusted[:priority].to_i
          ticket_params_adjusted[:priority] = [0, [3, priority_value].min].max # Ensures 0-3 (p4-p1)
        end

        if ticket_params_adjusted[:team_id].present?
          team = @organization.teams.find_by(id: ticket_params_adjusted[:team_id])
          unless team
            render json: { error: 'Team not found in this organization' }, status: :unprocessable_entity
            return
          end
          @ticket.team = team
        end

        if ticket_params_adjusted[:assignee_id].present?
          assignee = @ticket.team&.users&.find_by(id: ticket_params_adjusted[:assignee_id])
          unless assignee
            render json: { error: 'Assignee not found in the team' }, status: :unprocessable_entity
            return
          end
          @ticket.assignee = assignee
          @ticket.status = 'assigned'
        elsif ticket_params_adjusted[:assignee_id] == ''
          @ticket.assignee = nil
          @ticket.status = 'open'
        end

        if ticket_params_adjusted[:category].present? && !VALID_CATEGORIES.include?(ticket_params_adjusted[:category])
          render json: { error: "Invalid category. Allowed values are: #{VALID_CATEGORIES.join(', ')}" }, status: :unprocessable_entity
          return
        end

        if @ticket.update(ticket_params_adjusted)
          render json: ticket_attributes(@ticket)
        else
          render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @ticket.destroy!
        head :no_content
      end

      def assign_to_user
        unless current_user.teamlead? && current_user.team == @ticket.team
          return render json: { error: 'You are not authorized to assign this ticket' }, status: :unauthorized
        end

        assignee = @ticket.team.users.find_by(id: params[:user_id])
        unless assignee
          return render json: { error: 'User not found in the team' }, status: :unprocessable_entity
        end

        if @ticket.update(assignee: assignee, status: 'assigned')
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

      def escalate_to_problem
        unless current_user.teamlead?
          return render json: { error: 'Only team leads can escalate tickets to problems' }, status: :forbidden
        end

        # Removed restriction to only Incidents; now any ticket type can be escalated
        # If you want to restrict it back to Incidents, uncomment the following:
        # unless @ticket.ticket_type == 'Incident'
        #   return render json: { error: 'Only incident tickets can be escalated to problems' }, status: :unprocessable_entity
        # end

        @problem = Problem.new(
          description: @ticket.description,
          organization: @ticket.organization,
          team: @ticket.team,
          creator: current_user,
          ticket: @ticket
        )

        if @problem.save
          @ticket.update!(status: 'escalated')
          # Optionally notify relevant users
          if @ticket.assignee
            Notification.create!(
              user: @ticket.assignee,
              organization: @ticket.organization,
              message: "Ticket #{@ticket.ticket_number} has been escalated to a problem.",
              read: false,
              metadata: { ticket_id: @ticket.id, problem_id: @problem.id }
            )
          end
          render json: { message: 'Ticket escalated to problem', problem: @problem.as_json }, status: :created
        else
          render json: { errors: @problem.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def ticket_attributes(ticket)
        {
          id: ticket.id,
          title: ticket.title,
          description: ticket.description,
          ticket_type: ticket.ticket_type,
          status: ticket.status,
          urgency: ticket.urgency,
          priority: ticket.priority_before_type_cast, # Returns string like "p1"
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
          source: ticket.source,
          category: ticket.category,
          response_due_at: ticket.response_due_at,
          resolution_due_at: ticket.resolution_due_at,
          escalation_level: ticket.escalation_level,
          sla_breached: ticket.sla_breached,
          calculated_priority: ticket.calculated_priority
        }
      end

      # def set_organization_from_subdomain
      #   subdomain = request.subdomain.presence || 'default'
      #   @organization = Organization.find_by!(subdomain: subdomain)
      # rescue ActiveRecord::RecordNotFound
      #   render json: { error: 'Organization not found for this subdomain' }, status: :not_found
      #   nil
      # end

      def set_organization_from_subdomain
        subdomain = params[:organization_subdomain].presence || request.subdomain.presence || 'default'
        Rails.logger.info "Subdomain detected: #{subdomain}"
        @organization = Organization.find_by!(subdomain: subdomain)
      rescue ActiveRecord::RecordNotFound
        Rails.logger.error "Organization not found for subdomain: #{subdomain}"
        render json: { error: 'Organization not found for this subdomain' }, status: :not_found
      end
      

      def sla_params_changed?
        ticket_params[:urgency].present? || ticket_params[:impact].present? || ticket_params[:priority].present?
      end

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
          :customer, :source, :category, :assignee_id
        ).tap do |ticket_params|
          required_fields = %i[title description ticket_type urgency priority impact 
                              team_id caller_name caller_surname caller_email caller_phone 
                              customer source category]
          required_fields.each { |field| ticket_params.require(field) }
        end
      end

      def ticket_params_with_enums
        permitted_params = ticket_params.dup
        Rails.logger.debug "Raw ticket_params: #{permitted_params.inspect}"
        # Convert string urgency and impact to integers
        if permitted_params[:urgency].present?
          urgency_value = permitted_params[:urgency].downcase
          permitted_params[:urgency] = Ticket.urgencies[urgency_value] || raise("Invalid urgency: #{urgency_value}")
        end
        if permitted_params[:impact].present?
          impact_value = permitted_params[:impact].downcase
          permitted_params[:impact] = Ticket.impacts[impact_value] || raise("Invalid impact: #{impact_value}")
        end
        Rails.logger.debug "Converted ticket_params: #{permitted_params.inspect}"
        permitted_params
      end
    end
  end
end
