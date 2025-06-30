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

      
        @problem = Problem.new(problem_params.merge(
          creator: current_user,
          organization: @organization
        ))
      
        # Optionally associate with an incident and escalate it
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
          render json: { errors: @problem.errors.full_messages }, status: :unprocessable_entity
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
        param_subdomain = params[:subdomain] || params[:organization_subdomain] || params[:organization_id] || request.subdomains.first
      
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
          render json: { error: "Organization not found for subdomain: #{param_subdomain}" }, status: :not_found
        end
      end      
    end
  end
end
