# Description: Base controller for API endpoints.

module Api
  module V1
    class ApplicationController < ActionController::API
      include Pundit::Authorization

      # Remove CSRF protection for API (not needed for token-based auth)
      skip_before_action :verify_authenticity_token

      # Handle authorization errors
      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      # Authentication
      before_action :authenticate_user!, except: [:create] # Skip for login endpoint

      private

      # Authenticate user based on token
      def authenticate_user!
        token = request.headers['Authorization']&.split(' ')&.last
        unless token
          render json: { error: 'No authentication token provided' }, status: :unauthorized
          return
        end

        @current_user = User.find_by(auth_token: token)
        unless @current_user
          render json: { error: 'Invalid or expired token' }, status: :unauthorized
        end
      end

      # Current user accessor
      def current_user
        @current_user
      end

      # Handle authorization errors for API
      def user_not_authorized(exception)
        policy_name = exception.policy.class.to_s.underscore
        render json: {
          error: "You are not authorized to perform this action",
          details: "Not authorized to #{exception.query} on #{policy_name}"
        }, status: :forbidden
      end

      # Handle record not found errors
      def record_not_found(exception)
        render json: { error: "Resource not found", details: exception.message }, status: :not_found
      end

      # Helper to ensure organization context (optional, if needed in specific controllers)
      def set_organization_from_subdomain
        subdomain = request.subdomain.presence || params[:subdomain]
        @organization = Organization.find_by(subdomain: subdomain)
        unless @organization
          render json: { error: "Organization not found" }, status: :not_found
        end
      end

      # Helper to check if user belongs to the current organization
      def verify_user_organization
        if @organization && current_user&.organization_id != @organization.id
          render json: { error: "User does not belong to this organization" }, status: :forbidden
        end
      end
    end
  end
end