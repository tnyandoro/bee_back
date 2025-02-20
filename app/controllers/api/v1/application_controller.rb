# app/controllers/api/v1/application_controller.rb
module Api
  module V1
    class ApplicationController < ActionController::API
      include Pundit::Authorization

      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      before_action :authenticate_user!, except: [:create]

      private

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

      def current_user
        @current_user
      end

      def user_not_authorized(exception)
        policy_name = exception.policy.class.to_s.underscore
        render json: {
          error: "You are not authorized to perform this action",
          details: "Not authorized to #{exception.query} on #{policy_name}"
        }, status: :forbidden
      end

      def record_not_found(exception)
        render json: { error: "Resource not found", details: exception.message }, status: :not_found
      end

      def set_organization_from_subdomain
        # Log the subdomain for debugging
        Rails.logger.debug "Request subdomain: #{request.subdomain}"
        subdomain = request.subdomain.presence || params[:subdomain]
        Rails.logger.debug "Using subdomain: #{subdomain}"
        @organization = Organization.find_by(subdomain: subdomain)
        unless @organization
          render json: { error: "Organization not found for subdomain: #{subdomain}" }, status: :not_found
        end
      end

      def verify_user_organization
        if @organization && current_user&.organization_id != @organization.id
          render json: { error: "User does not belong to this organization" }, status: :forbidden
        end
      end
    end
  end
end
