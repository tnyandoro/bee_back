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
        Rails.logger.debug "Tickets fetched: #{@tickets.count}, Params: #{params.inspect}"
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
        Rails.logger.debug "Showing ticket with status: #{@ticket.status}"
        render json: ticket_attributes(@ticket)
      end

      def create
        Rails.logger.debug "Received ticket creation params: #{params.inspect}"
        ticket_params_adjusted = ticket_params_with_enums

        if ticket_params_adjusted[:priority].present?
          priority_value = ticket_params_adjusted[:priority].to_i
          ticket_params_adjusted[:priority] = [0, [3, priority_value].min].max
        end

        @ticket = @organization.tickets.new(ticket_params_adjusted)
        @ticket.creator = @creator
        @ticket.requester = @creator
        @ticket.user_id = @creator.id
        @ticket.ticket_number = ticket_params_adjusted[:ticket_number] || SecureRandom.hex(5)
        @ticket.reported_at = ticket_params_adjusted[:reported_at] ? Time.parse(ticket_params_adjusted[:reported_at]) : Time.current
        @ticket.status = 'open'

        Rails.logger.debug "Ticket attributes before save: #{@ticket.attributes.inspect}"

        if ticket_params_adjusted[:team_id].present?
          team = @organization.teams.find_by(id: ticket_params_adjusted[:team_id])
          unless team
            Rails.logger.error "Team ID #{ticket_params_adjusted[:team_id]} not found in organization #{@organization.id}"
            render json: { error: 'Team not found in this organization' }, status: :unprocessable_entity
            return
          end
          @ticket.team = team

          if ticket_params_adjusted[:assignee_id].present?
            assignee = team.users.find_by(id: ticket_params_adjusted[:assignee_id])
            unless assignee
              Rails.logger.error "Assignee ID #{ticket_params_adjusted[:assignee_id]} not found in team #{team.id}"
              render json: { error: 'Assignee not found in the selected team' }, status: :unprocessable_entity
              return
            end
            @ticket.assignee = assignee
            @ticket.status = 'assigned'
          end
        end

        unless VALID_CATEGORIES.include?(ticket_params_adjusted[:category])
          Rails.logger.error "Invalid category: #{ticket_params_adjusted[:category]}"
          render json: { error: "Invalid category. Allowed values are: #{VALID_CATEGORIES.join(', ')}" }, status: :unprocessable_entity
          return
        end

        if @ticket.save
          Rails.logger.debug "Ticket saved with status: #{@ticket.status}, ID: #{@ticket.id}"
          render json: ticket_attributes(@ticket), status: :created,
                 location: api_v1_organization_ticket_url(@organization.subdomain, @ticket)
        else
          Rails.logger.error "Ticket save failed: #{@ticket.errors.full_messages}"
          render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActionController::ParameterMissing => e
        Rails.logger.error "Parameter missing: #{e.message}"
        render json: { error: "Missing required parameter: #{e.param}" }, status: :unprocessable_entity
      rescue StandardError => e
        Rails.logger.error "Unexpected error in ticket creation: #{e.message}, Backtrace: #{e.backtrace.join("\n")}"
        render json: { error: "Internal server error: #{e.message}" }, status: :internal_server_error
      end

      def update
        ticket_params_adjusted = ticket_params_with_enums
        if ticket_params_adjusted[:priority].present?
          priority_value = ticket_params_adjusted[:priority].to_i
          ticket_params_adjusted[:priority] = [0, [3, priority_value].min].max
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

        @problem = Problem.new(
          description: @ticket.description,
          organization: @ticket.organization,
          team: @ticket.team,
          creator: current_user,
          ticket: @ticket
        )

        if @problem.save
          @ticket.update!(status: 'escalated')
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

      def resolve
        unless current_user.teamlead? || current_user.assignee == @ticket.assignee || current_user.admin?
          return render json: { error: 'You are not authorized to resolve this ticket' }, status: :forbidden
        end

        if @ticket.resolved? || @ticket.closed?
          return render json: { error: "Ticket is already resolved or closed" }, status: :unprocessable_entity
        end

        resolution_note = params[:resolution_note].presence || "Resolved by #{current_user.name}"
        if @ticket.update(status: 'resolved', resolved_at: Time.current, resolution_note: resolution_note)
          # Add resolution comment
          @ticket.comments.create!(
            content: "Ticket resolved: #{resolution_note}",
            user: current_user
          )

          # Notify requester and assignee
          Notification.create!(
            user: @ticket.requester,
            organization: @ticket.organization,
            message: "Ticket #{@ticket.ticket_number} has been resolved by #{current_user.name}",
            read: false,
            metadata: { ticket_id: @ticket.id }
          ) if @ticket.requester

          Notification.create!(
            user: @ticket.assignee,
            organization: @ticket.organization,
            message: "Ticket #{@ticket.ticket_number} has been resolved by #{current_user.name}",
            read: false,
            metadata: { ticket_id: @ticket.id }
          ) if @ticket.assignee && @ticket.assignee != current_user

          render json: ticket_attributes(@ticket), status: :ok
        else
          render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
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
          priority: ticket.priority_before_type_cast,
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
          calculated_priority: ticket.calculated_priority,
          resolved_at: ticket.resolved_at,
          resolution_note: ticket.resolution_note
        }
      end

      def set_organization_from_subdomain
        subdomain = params[:organization_subdomain].presence || request.subdomain.presence || 'default'
        Rails.logger.info "Subdomain detected: #{subdomain}"
        @organization = Organization.find_by!(subdomain: subdomain)
      rescue ActiveRecord::RecordNotFound
        Rails.logger.error "Organization not found for subdomain: #{subdomain}"
        render json: { error: 'Organization not found for this subdomain' }, status: :not_found
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
        scope = scope.where(assignee_id: params[:user_id]) if params[:user_id].present? && Rails.logger.debug("Filtering by assignee_id: #{params[:user_id]}")
        scope = scope.where(status: params[:status]) if params[:status].present? && Rails.logger.debug("Filtering by status: #{params[:status]}")
        scope = scope.where(ticket_type: params[:ticket_type]) if params[:ticket_type].present? && Rails.logger.debug("Filtering by ticket_type: #{params[:ticket_type]}")
        scope
      end

      def set_ticket
        @ticket = @organization.tickets.find_by!(ticket_number: params[:id])
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
          :customer, :source, :category, :assignee_id, :ticket_number, :reported_at,
          :creator_id, :requester_id
        ).tap do |ticket_params|
          required_fields = %i[title description ticket_type urgency impact team_id 
                              caller_name caller_surname caller_email caller_phone customer 
                              source category priority]
          required_fields.each do |field|
            ticket_params[field] = ticket_params[field].presence || nil
            unless ticket_params[field].present?
              Rails.logger.warn "Missing or empty required field: #{field}"
            end
          end
        end
      end

      def ticket_params_with_enums
        permitted_params = ticket_params.dup
        Rails.logger.debug "Raw ticket_params: #{permitted_params.inspect}"
        
        if permitted_params[:urgency].present?
          urgency_value = permitted_params[:urgency].downcase
          permitted_params[:urgency] = Ticket.urgencies[urgency_value]
          unless permitted_params[:urgency]
            Rails.logger.error "Invalid urgency value: #{urgency_value}"
            raise ArgumentError, "Invalid urgency: #{urgency_value}. Allowed values are: #{Ticket.urgencies.keys.join(', ')}"
          end
        end
        
        if permitted_params[:impact].present?
          impact_value = permitted_params[:impact].downcase
          permitted_params[:impact] = Ticket.impacts[impact_value]
          unless permitted_params[:impact]
            Rails.logger.error "Invalid impact value: #{impact_value}"
            raise ArgumentError, "Invalid impact: #{impact_value}. Allowed values are: #{Ticket.impacts.keys.join(', ')}"
          end
        end
        
        Rails.logger.debug "Converted ticket_params: #{permitted_params.inspect}"
        permitted_params
      end
    end
  end
end