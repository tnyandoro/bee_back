# frozen_string_literal: true
module Api
  module V1
    class ApplicationController < ActionController::API
      include Pundit::Authorization

      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      before_action :authenticate_user!, except: [:create] # Skips for SessionsController#create

      private

      def authenticate_user!
        token = request.headers['Authorization']&.split(' ')&.last
        Rails.logger.debug "Received Authorization Token: #{token}"

        unless token
          Rails.logger.debug "No authentication token provided in request headers"
          render json: { error: 'No authentication token provided' }, status: :unauthorized
          return
        end

        @current_user = User.find_by(auth_token: token)
        Rails.logger.debug "Queried User with token: #{@current_user&.id || 'Not found'}"

        unless @current_user
          Rails.logger.debug "Invalid or expired token detected: #{token}"
          render json: { error: 'Invalid or expired token' }, status: :unauthorized
          return
        end
        Rails.logger.debug "User authenticated successfully: #{@current_user.email}"
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

      # def set_organization_from_subdomain
      #   subdomain = request.subdomain.presence || 'default'
      #   @organization = Organization.find_by(subdomain: subdomain)
      #   unless @organization
      #     render json: { error: "Organization not found for subdomain: #{subdomain}" }, status: :not_found
      #   end
      # end

      def set_organization_from_subdomain
        # Force to use params[:subdomain] if available, ignoring request.subdomain
        subdomain = params[:subdomain].presence || request.subdomain.presence || 'default'
        
        Rails.logger.info "Subdomain detected from params: '#{params[:subdomain]}'"
        Rails.logger.info "Subdomain detected from request: '#{request.subdomain}'"
        Rails.logger.info "Final subdomain used: '#{subdomain}'"
        
        @organization = Organization.find_by(subdomain: subdomain)
        
        if @organization
          Rails.logger.info "Organization found: #{@organization.id} - #{@organization.subdomain}"
        else
          Rails.logger.error "Organization not found for subdomain: #{subdomain}"
          render json: { error: "Organization not found for subdomain: #{subdomain}" }, status: :not_found
        end
      end
      
      

      def verify_user_organization
        if @organization && current_user&.organization_id != @organization.id
          Rails.logger.debug "User #{@current_user.email} does not belong to organization #{@organization.subdomain}"
          render json: { error: "User does not belong to this organization" }, status: :forbidden
        end
      end
    end
  end
end
