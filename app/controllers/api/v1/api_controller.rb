module Api
  module V1
    class ApiController < ActionController::API
      include Pundit::Authorization
      include Rails.application.routes.url_helpers

      # --- Global error handlers ---
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActionController::RoutingError, with: :render_not_found
      rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
      rescue_from StandardError, with: :render_internal_server_error

      # --- Filters ---
      # before_action :verify_admin, only: %i[update destroy]  # if you have admin-only actions
      before_action :verify_admin, only: %i[update destroy], if: -> { self.respond_to?(:update) && self.respond_to?(:destroy) }
      before_action :set_organization_from_subdomain
      
      before_action :authenticate_user!, except: [:create]
      before_action :verify_user_organization, if: -> { @organization.present? }, except: [:create, :validate_subdomain]

      private

      def authenticate_user!
        render json: { error: "Unauthorized" }, status: :unauthorized unless current_user
      end

      def current_user
        @current_user ||= begin
          token = request.headers['Authorization']&.split(' ')&.last
          return nil unless token
          
          Rails.logger.debug "Authenticating with token: #{token.first(8)}..."
          
          # Find user by token AND organization
          User.find_by(
            auth_token: token,
            organization_id: @organization&.id
          )
        end
      end

      def set_organization_from_subdomain
        param_subdomain = params[:subdomain] || params[:organization_subdomain] || params[:organization_id] || request.subdomains.first

        Rails.logger.info "Subdomain sources: " \
          "params[:organization_id]=#{params[:organization_id]}, " \
          "params[:subdomain]=#{params[:subdomain]}, " \
          "params[:organization_subdomain]=#{params[:organization_subdomain]}, " \
          "request.subdomains=#{request.subdomains}"

        if Rails.env.development? && param_subdomain.blank?
          param_subdomain = 'demo'
        end

        if param_subdomain.blank? && Organization.count == 1
          @organization = Organization.first
          Rails.logger.info "Single-tenant fallback: Organization ID #{@organization.id}"
          return
        end

        unless param_subdomain.present?
          return render_error("Subdomain is missing in the request", status: :bad_request)
        end

        @organization = Organization.find_by("LOWER(subdomain) = ?", param_subdomain.downcase)

        unless @organization
          Rails.logger.error "Organization not found for subdomain: #{param_subdomain}"
          return render_error("Organization not found for subdomain: #{param_subdomain}", status: :not_found)
        end

        Rails.logger.info "Organization found: #{@organization.id} - #{@organization.subdomain}"
      end

      def verify_user_organization
        return unless current_user && @organization

        if current_user.organization_id != @organization.id
          Rails.logger.warn "User #{current_user.email} (org=#{current_user.organization_id}) tried to access org=#{@organization.id}"
          render_error("User does not belong to this organization", status: :forbidden)
        end
      end

      def render_success(data, message = "Success", status = :ok)
        render json: { message: message, data: data }, status: status
      end

      def render_error(errors, message: "An error occurred", details: nil, status: :unprocessable_entity)
        render json: { error: message, details: details || errors }, status: status
      end

      def render_not_found(exception = nil)
        render_error("Resource not found", details: exception&.message, status: :not_found)
      end

      def render_forbidden(exception = nil)
        render_error("You are not authorized to perform this action", details: exception&.message, status: :forbidden)
      end

      def render_internal_server_error(exception = nil)
        Rails.logger.error "Internal Server Error: #{exception&.message}"
        render_error("Internal server error", details: exception&.message, status: :internal_server_error)
      end
    end
  end
end