# frozen_string_literal: true
module Api
  module V1
    class ApplicationController < ActionController::API
      include Pundit::Authorization

      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      # Skip authentication for specific public actions like login and registration
      before_action :authenticate_user!, except: [:create]

      private

      # Authenticate user using token from Authorization header
      def authenticate_user!
        token = request.headers['Authorization']&.split(' ')&.last
        unless token
          Rails.logger.debug "No authentication token provided in request headers"
          render json: { error: 'No authentication token provided' }, status: :unauthorized
          return
        end

        @current_user = User.find_by(auth_token: token)
        unless @current_user
          Rails.logger.debug "Invalid or expired token: #{token}"
          render json: { error: 'Invalid or expired token' }, status: :unauthorized
          return
        end
        Rails.logger.debug "Authenticated user: #{@current_user.email}"
      end

      # Accessor for the current authenticated user
      def current_user
        @current_user
      end

      # Handle Pundit authorization errors
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

      # Set organization based on subdomain
      def set_organization_from_subdomain
        Rails.logger.debug "Request host: #{request.host}"
        subdomain = request.subdomain.presence || params[:subdomain]
        Rails.logger.debug "Extracted subdomain: #{subdomain}"
        
        if subdomain.blank?
          host = request.host
          if host =~ /^(.+)\.lvh\.me$/ || host =~ /^(.+)\.yourdomain\.com$/ # Add production domain if needed
            subdomain = $1
            Rails.logger.debug "Fallback subdomain from host: #{subdomain}"
          end
        end

        @organization = Organization.find_by(subdomain: subdomain)
        unless @organization
          Rails.logger.debug "Organization not found for subdomain: #{subdomain || 'none'}"
          render json: { error: "Organization not found for subdomain: #{subdomain || 'none'}" }, status: :not_found
        end
      end

      # Verify the current user belongs to the organization
      def verify_user_organization
        if @organization && current_user&.organization_id != @organization.id
          Rails.logger.debug "User #{@current_user.email} does not belong to organization #{@organization.subdomain}"
          render json: { error: "User does not belong to this organization" }, status: :forbidden
        end
      end
    end
  end
end
