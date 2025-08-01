module Api
  module V1
    class SessionsController < ApplicationController
      before_action :set_organization_from_subdomain, only: [:create]


      def create
        unless @organization
          Rails.logger.info "Organization not found for subdomain=#{params[:subdomain]}"
          render json: { error: "Organization not found" }, status: :not_found
          return
        end

        user = @organization.users.find_by(email: params[:email])
        unless user
          Rails.logger.info "Login failed: User not found for email=#{params[:email]}"
          render json: { error: "Invalid email or password" }, status: :unauthorized
          return
        end

        unless user.authenticate(params[:password])
          Rails.logger.info "Login failed: Invalid password for email=#{params[:email]}"
          render json: { error: "Invalid email or password" }, status: :unauthorized
          return
        end

        Rails.logger.info "User found: id=#{user.id}, email=#{user.email}, attributes=#{user.attributes.inspect}"

        unless user.role.present? && User.roles.key?(user.role)
          Rails.logger.error "User #{user.id} has invalid role: #{user.role.inspect}, db role: #{user.attributes['role']}"
          render json: { error: "User role is invalid or missing" }, status: :unprocessable_entity
          return
        end

        begin
          if user.auth_token.blank?
            loop do
              token = SecureRandom.hex(20)
              break user.update!(auth_token: token) unless User.exists?(auth_token: token)
            end
          end
        rescue StandardError => e
          Rails.logger.error "Failed to update auth_token for user #{user.id}: #{e.message}"
          render json: { error: "Failed to generate authentication token: #{e.message}" }, status: :internal_server_error
          return
        end

        response = {
          message: "Login successful",
          auth_token: user.auth_token,
          user: {
            id: user.id,
            email: user.email,
            name: user.name,
            role: user.role,
            organization_id: user.organization_id,
            team_id: user.team_id,
            team_ids: user.team_id ? [user.team_id] : []
          },
          subdomain: params[:subdomain],
          organization_id: @organization.id
        }

        Rails.logger.info "Login response: #{response.inspect}"
        render json: response, status: :ok
      end

      def destroy
        token = request.headers['Authorization']&.split(' ')&.last
        user = User.find_by(auth_token: token)

        if user
          user.update(auth_token: nil)
          Rails.logger.info "User #{user.id} logged out successfully"
          render json: { message: "Logged out successfully" }, status: :ok
        else
          Rails.logger.warn "Logout failed: Invalid token"
          render json: { error: "Invalid token" }, status: :unauthorized
        end
      end

      def verify
        if current_user
          Rails.logger.info "Token verified for user #{current_user.id}"
          render json: { message: "Token valid", role: current_user.role }, status: :ok
        else
          Rails.logger.warn "Token verification failed: Invalid token"
          render json: { error: "Invalid token" }, status: :unauthorized
        end
      end

      def verify_admin
        if current_user&.is_admin?
          Rails.logger.info "Admin token verified for user #{current_user.id}"
          head :ok
        else
          Rails.logger.warn "Admin verification failed: User not admin or invalid token"
          head :forbidden
        end
      end      

      private

      def current_user
        token = request.headers['Authorization']&.split(' ')&.last
        return unless token

        @current_user ||= User.find_by(auth_token: token).tap do |user|
          Rails.logger.warn "No user found for token" unless user
        end
      end
    end
  end
end