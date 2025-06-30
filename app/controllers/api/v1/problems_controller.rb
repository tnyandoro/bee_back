# frozen_string_literal: true
module Api
  module V1
    class ProblemsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_organization_from_subdomain
      before_action :set_problem, only: %i[show update destroy]

      def index
        if params[:organization_id]
          @organization = Organization.find(params[:organization_id])
          @problems = Problem.joins(:ticket).where(tickets: { organization_id: @organization.id })
        elsif params[:user_id]
          @user = User.find(params[:user_id])
          @problems = @user.problems
        else
          @problems = @organization.problems
        end
        render json: @problems
      end

      def show
        render json: @problem
      end

      def create
        Rails.logger.debug "Problem params: #{params.inspect}"
        Rails.logger.info "Request params: #{params.to_unsafe_h}"
        Rails.logger.info "Resolved subdomain: #{params[:subdomain]}"
        Rails.logger.info "Organization from controller: #{@organization&.id} #{@organization&.subdomain}"
      
        # Build ticket params from problem_params, set ticket_type to 'Problem'
        ticket_attrs = problem_params.slice(
          :title, :description, :urgency, :priority, :impact,
          :team_id, :caller_name, :caller_surname, :caller_email, :caller_phone,
          :customer, :source, :category, :assignee_id
        ).merge(
          ticket_type: 'Problem',
          creator: current_user,
          requester: current_user,
          reported_at: Time.current,
          status: 'open'
        )
      
        # Convert urgency and impact enums (you can extract this into a shared method)
        if ticket_attrs[:urgency].present?
          urgency_value = ticket_attrs[:urgency].downcase
          ticket_attrs[:urgency] = Ticket.urgencies[urgency_value]
        end
        if ticket_attrs[:impact].present?
          impact_value = ticket_attrs[:impact].downcase
          ticket_attrs[:impact] = Ticket.impacts[impact_value]
        end
      
        @ticket = @organization.tickets.new(ticket_attrs)
      
        if @ticket.save
          @problem = Problem.new(
            ticket: @ticket,
            creator: current_user,
            organization: @organization,
            team: @ticket.team
          )
      
          if params[:problem][:related_incident_id].present?
            related_ticket = @organization.tickets.find_by(id: params[:problem][:related_incident_id])
            if related_ticket
              @problem.related_incident_id = related_ticket.id
              related_ticket.update(status: 'escalated')
            end
          end
      
          if @problem.save
            render json: @problem, status: :created, location: api_v1_organization_problem_url(subdomain: @organization.subdomain, id: @problem.id)
          else
            Rails.logger.debug "Problem errors: #{@problem.errors.full_messages}"
            # If problem fails, rollback ticket creation as well
            @ticket.destroy
            render json: { errors: @problem.errors.full_messages }, status: :unprocessable_entity
          end
        else
          Rails.logger.debug "Ticket errors: #{@ticket.errors.full_messages}"
          render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
        end
      
      rescue => e
        Rails.logger.error "Error creating problem: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: { error: 'Internal server error', details: e.message }, status: :internal_server_error
      end
      
      def update
        if @problem.update(problem_params)
          render json: @problem
        else
          render json: { errors: @problem.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @problem.destroy!
        head :no_content
      end

      private

      def set_problem
        @problem = @organization.problems.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Problem not found in this organization' }, status: :not_found
      end

      def problem_params
        key = params[:problem].present? ? :problem : :ticket
      
        unless params[key].present?
          raise ActionController::ParameterMissing.new("problem or ticket")
        end
      
        params.require(key).permit(
          :title, :description, :ticket_id, :related_incident_id,
          :team_id, :assignee_id, :urgency, :priority, :impact,
          :caller_name, :caller_surname, :caller_email, :caller_phone,
          :customer, :source, :category
        )
      end              

      def set_organization_from_subdomain
        param_subdomain = params[:organization_subdomain] || params[:subdomain] || params[:organization_id] || request.subdomains.first
      
        if Rails.env.development? && param_subdomain.blank?
          param_subdomain = 'demo'
        end
      
        if param_subdomain.blank? && Organization.count == 1
          @organization = Organization.first
          return
        end
      
        unless param_subdomain.present?
          render json: { error: "Subdomain is missing in the request" }, status: :bad_request
          return
        end
      
        @organization = Organization.find_by("LOWER(subdomain) = ?", param_subdomain.downcase)
      
        unless @organization
          Rails.logger.warn "Subdomain '#{param_subdomain}' could not be resolved to any organization"
          render json: { error: "Organization not found for subdomain: #{param_subdomain}" }, status: :not_found
        end
      end
    end
  end
end
