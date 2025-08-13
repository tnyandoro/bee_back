# frozen_string_literal: true
module Api
  module V1
    class ProblemsController < Api::V1::ApiController
      before_action :set_organization_from_subdomain, only: %i[index show create update destroy]
      before_action :set_problem, only: %i[show update destroy]

      def index
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 10).to_i
        per_page = [per_page, 100].min

        if page < 1 || per_page < 1
          render json: { error: "Invalid pagination parameters" }, status: :unprocessable_entity
          return
        end

        cache_key = "problems:v1:org_#{@organization.id}:page_#{page}:per_#{per_page}"
        problems = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
          scope = @organization.problems.order(created_at: :desc)
          if params[:user_id].present?
            user = User.find_by(id: params[:user_id], organization_id: @organization.id)
            scope = scope.where(user_id: user.id) if user
          end
          scope.paginate(page: page, per_page: per_page).map do |p|
            {
              id: p.id,
              description: p.description || "Untitled",
              created_at: p.created_at&.iso8601 || Time.current.iso8601,
              updated_at: p.updated_at&.iso8601 || Time.current.iso8601,
              team: p.team ? { id: p.team.id, name: p.team.name } : nil,
              creator: p.creator ? { id: p.creator.id, name: p.creator.name } : nil,
              user: p.user ? { id: p.user.id, name: p.user.name } : nil,
              ticket_id: p.ticket_id,
              related_incident_id: p.related_incident_id
            }
          end
        end

        Rails.logger.info "[ProblemsController#index] Retrieved #{problems.count} problems for org_id=#{@organization.id}"
        render json: {
          data: problems,
          message: "Problems retrieved successfully",
          pagination: {
            current_page: page,
            total_pages: (@organization.problems.count.to_f / per_page).ceil,
            total_entries: @organization.problems.count
          },
          meta: { fetched_at: Time.current.iso8601, timezone: Time.zone.name, subdomain: @organization.subdomain }
        }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: "User not found in this organization" }, status: :not_found
      rescue => e
        handle_exception('index', e)
      end

      def show
        render json: problem_attributes(@problem)
      end

      def create
        log_debug_context('create', params)
        unless current_user.team_leader? || current_user.super_user? || current_user.department_manager? || current_user.general_manager? || current_user.domain_admin?
          return render json: { error: "Only team leads or higher can create problems" }, status: :forbidden
        end

        ticket_attrs = build_ticket_attributes
        @ticket = @organization.tickets.new(ticket_attrs)

        ActiveRecord::Base.transaction do
          if @ticket.save
            @problem = build_problem_from_ticket(@ticket)
            handle_related_incident(@problem)

            if @problem.save
              render json: problem_attributes(@problem), status: :created,
                     location: api_v1_organization_problem_url(subdomain: @organization.subdomain, id: @problem.id)
            else
              log_failure('Problem', @problem)
              raise ActiveRecord::Rollback
            end
          else
            log_failure('Ticket', @ticket)
            render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end
        end
      rescue => e
        handle_exception('create', e)
      end

      def update
        log_debug_context('update', params)
        unless current_user.team_leader? || current_user.super_user? || current_user.department_manager? || current_user.general_manager? || current_user.domain_admin?
          return render json: { error: "Only team leads or higher can update problems" }, status: :forbidden
        end

        update_attrs = safe_problem_params.to_h.symbolize_keys.except(:organization_id, :creator_id, :ticket_id, :related_incident_id)

        if @problem.update(update_attrs)
          Rails.logger.info "[ProblemsController#update] Problem ##{@problem.id} updated successfully"
          render json: problem_attributes(@problem)
        else
          log_failure('Problem', @problem, update_attrs)
          render json: { errors: @problem.errors.full_messages }, status: :unprocessable_entity
        end
      rescue => e
        handle_exception('update', e)
      end

      def destroy
        unless current_user.is_admin? || current_user.domain_admin?
          return render json: { error: "Only admins can delete problems" }, status: :forbidden
        end
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

        params.require(key).permit(
          :title, :description, :ticket_id, :related_incident_id,
          :team_id, :assignee_id, :urgency, :priority, :impact,
          :caller_name, :caller_surname, :caller_email, :caller_phone,
          :customer, :source, :category
        )
      end

      def build_ticket_attributes
        raw = safe_problem_params.to_h.symbolize_keys
        Rails.logger.debug "[ProblemsController] Incoming ticket attributes: #{raw.inspect}"

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
          user_id: current_user.id,
          organization_id: ticket.organization_id,
          team_id: ticket.team_id,
          description: ticket.description
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
        Rails.logger.info "[ProblemsController##{action}] Organization: #{@organization&.id} (#{@organization&.subdomain})"
      end

      def handle_exception(action, exception)
        Rails.logger.error "[ProblemsController##{action}] Exception: #{exception.message}"
        Rails.logger.error exception.backtrace.join("\n")
        render json: { error: 'Internal server error', details: exception.message }, status: :internal_server_error
      end

      def problem_attributes(problem)
        {
          id: problem.id,
          description: problem.description || "Untitled",
          created_at: problem.created_at&.iso8601 || Time.current.iso8601,
          updated_at: problem.updated_at&.iso8601 || Time.current.iso8601,
          team: problem.team ? { id: problem.team.id, name: problem.team.name } : nil,
          creator: problem.creator ? { id: problem.creator.id, name: problem.creator.name } : nil,
          user: problem.user ? { id: problem.user.id, name: problem.user.name } : nil,
          ticket_id: problem.ticket_id,
          related_incident_id: problem.related_incident_id
        }
      end
    end
  end
end
