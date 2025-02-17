# frozen_string_literal: true

module Api
    module V1
      class TicketsController < ApplicationController
        before_action :set_ticket, only: %i[show update destroy assign_to_user escalate_to_problem]
        before_action :set_organization
        before_action :set_creator, only: [:create]
        before_action :validate_params, only: [:index]
  
        VALID_STATUSES = %w[open assigned escalated closed suspended resolved pending].freeze
        VALID_CATEGORIES = %w[technical billing support hardware software other].freeze
  
        # GET /organizations/:organization_id/tickets
        def index
          return render json: { error: 'organization_id is required.' }, status: :unprocessable_entity unless params[:organization_id].present?
  
          @tickets = apply_filters(Ticket.where(organization_id: params[:organization_id]))
          render json: @tickets
        end
  
        # GET /organizations/:organization_id/tickets/:id
        def show
          render json: @ticket
        end
  
        # POST /organizations/:organization_id/tickets
        def create
          @ticket = @organization.tickets.new(ticket_params)
          @ticket.creator = @creator
          @ticket.requester = @creator
  
          if params[:ticket][:team_id].present?
            team = @organization.teams.find_by(id: params[:ticket][:team_id])
            return render json: { error: 'Team not found in this organization' }, status: :unprocessable_entity unless team
  
            @ticket.team = team
          end
  
          if @ticket.save
            render json: @ticket, status: :created, location: organization_ticket_url(@organization, @ticket)
          else
            render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
          end
        end
  
        # PATCH/PUT /organizations/:organization_id/tickets/:id
        def update
          if params[:ticket][:team_id].present?
            team = @organization.teams.find_by(id: params[:ticket][:team_id])
            return render json: { error: 'Team not found in this organization' }, status: :unprocessable_entity unless team
  
            @ticket.team = team
          end
  
          if params[:ticket][:assignee_id].present?
            assignee = @ticket.team.users.find_by(id: params[:ticket][:assignee_id])
            return render json: { error: 'Assignee not found in the team' }, status: :unprocessable_entity unless assignee
  
            @ticket.assignee = assignee
          end
  
          if @ticket.update(ticket_params)
            render json: @ticket
          else
            render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
          end
        end
  
        # DELETE /organizations/:organization_id/tickets/:id
        def destroy
          @ticket.destroy!
          head :no_content
        end
  
        # POST /organizations/:organization_id/tickets/:id/assign_to_user
        def assign_to_user
          return render json: { error: 'You are not authorized to assign this ticket' }, status: :unauthorized unless current_user.teamlead? && current_user.team == @ticket.team
  
          assignee = @ticket.team.users.find_by(id: params[:user_id])
          return render json: { error: 'User not found in the team' }, status: :unprocessable_entity unless assignee
  
          if @ticket.update(assignee: assignee)
            SendTicketAssignmentEmailsJob.perform_later(@ticket, @ticket.team, assignee)
            Notification.create!(
              user: assignee,
              organization: @ticket.organization,
              message: "You have been assigned a new ticket: #{@ticket.title}",
              read: false,
              metadata: { ticket_id: @ticket.id }
            )
            render json: @ticket, status: :ok
          else
            render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
          end
        end
  
        # POST /organizations/:organization_id/tickets/:id/escalate_to_problem
        def escalate_to_problem
          return render json: { error: 'Only team leads can escalate tickets to problems' }, status: :forbidden unless current_user.teamlead?
          return render json: { error: 'Only incident tickets can be escalated to problems' }, status: :unprocessable_entity unless @ticket.incident?
  
          problem = Problem.create!(
            description: @ticket.description,
            organization: @ticket.organization,
            team: @ticket.team,
            creator: current_user,
            reported_at: Time.current
          )
  
          @ticket.update!(problem: problem)
          render json: { message: 'Ticket escalated to problem', problem: ProblemSerializer.new(problem) }, status: :created
        end
  
        private
  
        def validate_params
          return if validate_status && validate_category
  
          false
        end
  
        def validate_status
          return true unless params[:status].present?
          return true if VALID_STATUSES.include?(params[:status])
  
          render json: { error: "Invalid status. Allowed values are: #{VALID_STATUSES.join(', ')}" }, status: :unprocessable_entity
          false
        end
  
        def validate_category
          return true unless params[:category].present?
          return true if VALID_CATEGORIES.include?(params[:category])
  
          render json: { error: "Invalid category. Allowed values are: #{VALID_CATEGORIES.join(', ')}" }, status: :unprocessable_entity
          false
        end
  
        def apply_filters(scope)
          scope = scope.where(assignee_id: params[:user_id]) if params[:user_id].present?
          scope = scope.where(status: params[:status]) if params[:status].present?
          scope = scope.where(category: params[:category]) if params[:category].present?
          scope
        end
  
        def set_ticket
          @ticket = Ticket.find(params[:id])
        end
  
        def set_organization
          @organization = Organization.find(params[:organization_id])
        rescue ActiveRecord::RecordNotFound
          render json: { error: 'Organization not found' }, status: :not_found
        end
  
        def set_creator
          @creator = current_user
          render json: { error: 'User not authenticated' }, status: :unauthorized unless @creator
        end
  
        def ticket_params
          params.require(:ticket).permit(
            :title, :description, :ticket_type, :status, :urgency, :priority, :impact,
            :assignee_id, :team_id, :category, :caller_name, :caller_surname, :caller_email,
            :caller_phone, :customer, :source, :reported_at, :requester_id
          ).tap do |ticket_params|
            required_fields = %i[
              title description ticket_type status urgency priority impact
              team_id category caller_name caller_surname caller_email caller_phone
              customer source reported_at
            ]
            required_fields.each { |field| ticket_params.require(field) }
          end
        end
      end
    end
  end
  