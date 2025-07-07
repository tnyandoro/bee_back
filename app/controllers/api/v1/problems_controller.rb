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
        log_debug_context('create', params)

        ticket_attrs = build_ticket_attributes
        @ticket = @organization.tickets.new(ticket_attrs)

        if @ticket.save
          @problem = build_problem_from_ticket(@ticket)
          handle_related_incident(@problem)

          if @problem.save
            render json: @problem, status: :created,
                   location: api_v1_organization_problem_url(subdomain: @organization.subdomain, id: @problem.id)
          else
            log_failure('Problem', @problem)
            @ticket.destroy
            render json: { errors: @problem.errors.full_messages }, status: :unprocessable_entity
          end
        else
          log_failure('Ticket', @ticket)
          render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
        end
      rescue => e
        handle_exception('create', e)
      end

      def update
        log_debug_context('update', params)
        update_attrs = safe_problem_params.to_h.symbolize_keys.except(:organization_id, :creator_id, :ticket_id)

        if @problem.update(update_attrs)
          Rails.logger.info "[ProblemsController#update] Problem ##{@problem.id} updated successfully"
          render json: @problem
        else
          log_failure('Problem', @problem, update_attrs)
          render json: { errors: @problem.errors.full_messages }, status: :unprocessable_entity
        end
      rescue => e
        handle_exception('update', e)
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

      def set_organization_from_subdomain
        param_subdomain = params[:organization_subdomain] || params[:subdomain] || params[:organization_id] || request.subdomains.first

        if Rails.env.development? && param_subdomain.blank?
          param_subdomain = 'demo'
        end

        if param_subdomain.blank? && Organization.count == 1
          @organization = Organization.first and return
        end

        if param_subdomain.blank?
          render json: { error: "Subdomain is missing in the request" }, status: :bad_request and return
        end

        @organization = Organization.find_by("LOWER(subdomain) = ?", param_subdomain.downcase)
        unless @organization
          render json: { error: "Organization not found for subdomain: #{param_subdomain}" }, status: :not_found
        end
      end

      def problem_params_key
        params[:problem].present? ? :problem : :ticket
      end

      def safe_problem_params
        key = problem_params_key
        unless params[key].present?
          raise ActionController::ParameterMissing.new("problem or ticket")
        end
      
        # Use to_h AFTER permitting to avoid losing data
        params.require(key).permit(
          :title, :description, :ticket_id, :related_incident_id,
          :team_id, :assignee_id, :urgency, :priority, :impact,
          :caller_name, :caller_surname, :caller_email, :caller_phone,
          :customer, :source, :category
        )
      end      

      def build_ticket_attributes
        raw = safe_problem_params.to_h.symbolize_keys 
        Rails.logger.debug "[ProblemsController] Incoming ticket attributes: #{raw.inspect}"  # ✅ Log after definition
      
        attrs = raw.slice(
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
      
        normalize_enum!(attrs, :urgency, Ticket.urgencies)
        normalize_enum!(attrs, :impact, Ticket.impacts)
      
        attrs
      end      

      def normalize_enum!(attrs, key, enum_hash)
        value = attrs[key]
        return unless value.present?

        normalized = enum_hash[value.to_s.downcase]
        attrs[key] = normalized if normalized
      end

      def build_problem_from_ticket(ticket)
        Problem.new(
          ticket_id: ticket.id,
          creator_id: current_user.id,
          organization_id: ticket.organization_id,
          team_id: ticket.team_id,
          description: ticket.description # ✅ Add this line
        )
      end      

      def handle_related_incident(problem)
        related_id = params.dig(:problem, :related_incident_id)
        return unless related_id.present?

        related_ticket = @organization.tickets.find_by(id: related_id)
        if related_ticket
          problem.related_incident_id = related_ticket.id
          related_ticket.update(status: 'escalated')
        else
          Rails.logger.warn "[ProblemsController] Related incident ##{related_id} not found"
        end
      end

      def log_failure(resource_name, record, attempted_attrs = nil)
        Rails.logger.warn "[ProblemsController] #{resource_name} failed: #{record.errors.full_messages}"
        Rails.logger.debug "[ProblemsController] #{resource_name} attributes: #{record.attributes.inspect}"
        Rails.logger.debug "[ProblemsController] Attempted update: #{attempted_attrs.inspect}" if attempted_attrs
      end

      def log_debug_context(action, params)
        Rails.logger.debug "[ProblemsController##{action}] Params: #{params.to_unsafe_h}"
        Rails.logger.info  "[ProblemsController##{action}] Organization: #{@organization&.id} (#{@organization&.subdomain})"
      end

      def handle_exception(action, exception)
        Rails.logger.error "[ProblemsController##{action}] Exception: #{exception.message}"
        Rails.logger.error exception.backtrace.join("\n")
        render json: { error: 'Internal server error', details: exception.message }, status: :internal_server_error
      end
    end
  end
end
