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
      before_action :set_organization_from_subdomain
      before_action :authenticate_user!
      before_action :verify_user_organization, if: -> { current_user.present? && @organization.present? }

      private

      # ---------------------------
      # Authentication
      # ---------------------------
      def authenticate_user!
        render_error("Unauthorized", status: :unauthorized) unless current_user
      end

      def current_user
        return @current_user if defined?(@current_user)

        token = request.headers['Authorization']&.split(' ')&.last
        return @current_user = nil if token.blank?

        payload = JwtService.decode(token)
        if payload && payload["exp"] > Time.now.to_i
          @current_user = User.find_by(id: payload["user_id"], organization_id: payload["org_id"])
        else
          @current_user = nil
        end
      rescue JWT::DecodeError => e
        Rails.logger.warn "JWT decode error: #{e.message}"
        @current_user = nil
      end

      # ---------------------------
      # Organization resolution
      # ---------------------------
      def set_organization_from_subdomain
        param_subdomain = params[:subdomain] || params[:organization_subdomain] || request.subdomains.first
        param_subdomain = 'demo' if Rails.env.development? && param_subdomain.blank?

        if param_subdomain.blank? && Organization.count == 1
          @organization = Organization.first
          return
        end

        return render_error("Subdomain is missing", status: :bad_request) unless param_subdomain.present?

        @organization = Organization.find_by("LOWER(subdomain) = ?", param_subdomain.downcase)
        return render_error("Organization not found", status: :not_found) unless @organization
      end

      # ---------------------------
      # Authorization checks
      # ---------------------------
      def verify_user_organization
        return if current_user.nil? || @organization.nil?

        if current_user.organization_id != @organization.id
          render_error("User does not belong to this organization", status: :forbidden)
        end
      end

      # ---------------------------
      # Rendering helpers
      # ---------------------------
      def render_success(data, message = "Success", status: :ok)
        render json: { message: message, data: data }, status: status
      end

      def render_error(errors, message: nil, details: nil, status: :unprocessable_entity)
        render json: {
          error: message || "An error occurred",
          details: details || errors
        }, status: status
      end

      def render_not_found(exception = nil)
        render_error("Resource not found", details: exception&.message, status: :not_found)
      end

      def render_forbidden(exception = nil)
        render_error("You are not authorized to perform this action", details: exception&.message, status: :forbidden)
      end

      def render_internal_server_error(exception = nil)
        Rails.logger.error "Internal Server Error: #{exception&.message}"
        render_error("Internal server error", details: Rails.env.production? ? nil : exception&.message, status: :internal_server_error)
      end
    end
  end
end
