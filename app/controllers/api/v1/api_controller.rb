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
        render_error(message: ErrorCodes::Messages.UNAUTHORIZED, error_code: ErrorCodes::Codes.UNAUTHORIZED, status: :unauthorized) unless current_user
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
      # def set_organization_from_subdomain
      #   param_subdomain = params[:subdomain] || params[:organization_subdomain] || request.subdomains.first
      #   param_subdomain = 'demo' if Rails.env.development? && param_subdomain.blank?

      #   if param_subdomain.blank? && Organization.count == 1
      #     @organization = Organization.first
      #     return
      #   end

      #   return render_error("Subdomain is missing", status: :bad_request) unless param_subdomain.present?

      #   @organization = Organization.find_by("LOWER(subdomain) = ?", param_subdomain.downcase)
      #   return render_error("Organization not found", status: :not_found) unless @organization
      # end

      def set_organization_from_subdomain
        param_subdomain = params[:subdomain] || params[:organization_subdomain] || request.subdomains.first
        param_subdomain = 'demo' if Rails.env.development? && param_subdomain.blank?

        if param_subdomain.blank? && Organization.count == 1
          @organization = Organization.first
          return
        end

        return render_error(message: ErrorCodes::Messages.SUBDOMAIN_MISSING, error_code: ErrorCodes::Codes.SUBDOMAIN_MISSING, status: :bad_request) unless param_subdomain.present?

        @organization = Organization.find_by("LOWER(subdomain) = ?", param_subdomain.downcase)
        return render_error(message: ErrorCodes::Messages.ORGANIZATION_NOT_FOUND, error_code: ErrorCodes::Codes.ORGANIZATION_NOT_FOUND, status: :not_found) unless @organization
      end

      # ---------------------------
      # Authorization checks
      # ---------------------------
      def verify_user_organization
        return if current_user.nil? || @organization.nil?

        if current_user.organization_id != @organization.id
          render_error(message: ErrorCodes::Messages.USER_NOT_IN_ORGANIZATION, error_code: ErrorCodes::Codes.USER_NOT_IN_ORGANIZATION, status: :forbidden)
        end
      end

      # ---------------------------
      # Rendering helpers
      # ---------------------------
      def render_success(data, message = "Success", status: :ok)
        render json: { message: message, data: data }, status: status
      end

      def render_error(errors: nil, message: nil, error_code: nil, details: nil, status: :unprocessable_entity)
        render json: {
          error: message || "An error occurred",
          error_code: error_code || 1,
          details: details || errors || [message] || ["An error occurred"]
        }, status: status
      end

      def render_not_found(exception = nil)
        render_error(message: ErrorCodes::Messages.RESOURCE_NOT_FOUND, error_code: ErrorCodes::Codes.RESOURCE_NOT_FOUND, details: exception&.message, status: :not_found)
      end

      def render_forbidden(exception = nil)
        render_error(message: ErrorCodes::Messages.FORBIDDEN, error_code: ErrorCodes::Codes.FORBIDDEN, details: exception&.message, status: :forbidden)
      end

      def render_internal_server_error(exception = nil)
        Rails.logger.error "Internal Server Error: #{exception&.message}"
        render_error(message: ErrorCodes::Messages.INTERNAL_SERVER_ERROR, error_code: ErrorCodes::Codes.INTERNAL_SERVER_ERROR, details: Rails.env.production? ? nil : exception&.message, status: :internal_server_error)
      end
    end
  end
end
