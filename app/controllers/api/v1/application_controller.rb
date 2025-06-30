# app/controllers/api/v1/application_controller.rb
module Api
  module V1
    class ApplicationController < ActionController::API
      include Pundit::Authorization

      # Global error handlers
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActionController::RoutingError, with: :render_not_found
      rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
      rescue_from StandardError, with: :render_internal_server_error

      # Filters
      before_action :authenticate_user!, except: [:create]
      before_action :set_organization_from_subdomain
      before_action :verify_user_organization, if: -> { @organization.present? }

      private

      # --- Centralized Authentication Logic ---
      def authenticate_user!
        render json: { error: "Unauthorized" }, status: :unauthorized unless current_user
      end

      def current_user
        @current_user ||= begin
          token = request.headers['Authorization']&.split(' ')&.last
          Rails.logger.debug "Authenticating with token: #{token}"
          User.find_by(auth_token: token)
        end
      end

      def current_user_email
        current_user&.email
      end

      def set_organization_from_subdomain
        # param_subdomain = params[:organization_id] || params[:subdomain] || params[:organization_subdomain] || request.subdomains.first
        param_subdomain = params[:subdomain] || params[:organization_id] || params[:organization_subdomain] || request.subdomains.first

        Rails.logger.info "Subdomain sources: params[:organization_id]=#{params[:organization_id]}, params[:subdomain]=#{params[:subdomain]}, params[:organization_subdomain]=#{params[:organization_subdomain]}, request.subdomains=#{request.subdomains}"

        if Rails.env.development? && param_subdomain.blank?
          param_subdomain = 'demo'
        end

        if param_subdomain.blank? && Organization.count == 1
          @organization = Organization.first
          Rails.logger.info "Single-tenant fallback: Organization ID #{@organization.id}"
          return
        end

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
      
      def verify_user_organization
        if current_user && current_user.organization_id != @organization&.id
          Rails.logger.debug "User #{current_user_email} does not belong to organization #{@organization.subdomain}"
          render_error("User does not belong to this organization", status: :forbidden)
        end
      end

      # --- Response Helpers ---
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
