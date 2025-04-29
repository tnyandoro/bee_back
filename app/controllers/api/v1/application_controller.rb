module Api
  module V1
    class ApplicationController < ActionController::API
      include Pundit::Authorization

      # Global exception handling
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActionController::RoutingError, with: :render_not_found
      rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
      rescue_from StandardError, with: :render_internal_server_error

      # Before actions
      before_action :authenticate_user!, except: [:create] # Skips for SessionsController#create
      before_action :set_organization_from_subdomain
      before_action :verify_user_organization, if: -> { @organization.present? }

      private

      # Authenticates user by token sent in the Authorization header
      def authenticate_user!
        token = request.headers['Authorization']&.split(' ')&.last
        Rails.logger.debug "Received Authorization Token: #{token}"

        unless token.present?
          Rails.logger.debug "No authentication token provided in request headers"
          return render_error("No authentication token provided", status: :unauthorized)
        end

        @current_user = User.find_by(auth_token: token)
        Rails.logger.debug "Queried User with token: #{@current_user&.id || 'Not found'}"

        unless @current_user
          Rails.logger.debug "Invalid or expired token detected: #{token}"
          return render_error("Invalid or expired token", status: :unauthorized)
        end

        Rails.logger.debug "User authenticated successfully: #{@current_user.email}"
      end

      # Memoized current user
      # def current_user
      #   @current_user ||= User.find_by(auth_token: request.headers['Authorization']&.split(' ')&.last)
      # end

      def current_user
        @current_user ||= User.find_by(auth_token: request.headers['Authorization']&.split(' ')&.last)
      end

      def current_user_email
        current_user&.email # Use safe navigation (&.) to avoid errors if current_user is nil
      end

      # Handles subdomain resolution
      # def set_organization_from_subdomain
      #   param_subdomain = params[:subdomain].presence || request.subdomains.first.presence

      #   Rails.logger.info "Finding organization with param_subdomain: #{param_subdomain}"

      #   unless param_subdomain.present?
      #     return render_error("Subdomain is missing in the request", status: :bad_request)
      #   end

      #   @organization = Organization.find_by("LOWER(subdomain) = ?", param_subdomain.downcase)

      #   if @organization
      #     Rails.logger.info "Organization found: #{@organization.id} - #{@organization.subdomain}"
      #   else
      #     Rails.logger.error "Organization not found for subdomain: #{param_subdomain}"
      #     render_error("Organization not found for subdomain: #{param_subdomain}", status: :not_found)
      #   end
      # end

      def set_organization_from_subdomain
        # Check all possible parameter names for the subdomain
        param_subdomain = params[:organization_id] || 
                        params[:subdomain] || 
                        params[:organization_subdomain] || 
                        request.subdomains.first

        Rails.logger.info "Finding organization with subdomain: #{param_subdomain}"

        unless param_subdomain.present?
          render_error("Subdomain is missing in the request", status: :bad_request)
          return
        end

        @organization = Organization.find_by("LOWER(subdomain) = ?", param_subdomain.downcase)

        if @organization
          Rails.logger.info "Organization found: #{@organization.id} - #{@organization.subdomain}"
        else
          Rails.logger.error "Organization not found for subdomain: #{param_subdomain}"
          render_error("Organization not found for subdomain: #{param_subdomain}", status: :not_found)
        end
      end

      # Ensures the current user belongs to the organization context
      def verify_user_organization
        if @organization && current_user && current_user.organization_id != @organization.id
          Rails.logger.debug "User #{current_user_email} does not belong to organization #{@organization.subdomain}"
          render_error("User does not belong to this organization", status: :forbidden)
        end
      end

      # Helper method for rendering success responses
      def render_success(data, message = "Success", status = :ok)
        render json: { message: message, data: data }, status: status
      end

      # Helper method for rendering error responses
      def render_error(errors, message: "An error occurred", details: nil, status: :unprocessable_entity)
        render json: { error: message, details: details || errors }, status: status
      end


      # Renders a standardized 404 Not Found response
      def render_not_found(exception = nil)
        render_error("Resource not found", details: exception&.message, status: :not_found)
      end

      # Renders a standardized 403 Forbidden response
      def render_forbidden(exception = nil)
        render_error("You are not authorized to perform this action", details: exception&.message, status: :forbidden)
      end

      # Renders a standardized 500 Internal Server Error response
      def render_internal_server_error(exception = nil)
        Rails.logger.error "Internal Server Error: #{exception&.message}"
        render_error("Internal server error", details: exception&.message, status: :internal_server_error)
      end
    end
  end
end
