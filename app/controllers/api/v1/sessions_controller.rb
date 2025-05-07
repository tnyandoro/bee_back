module Api
  module V1
    class SessionsController < ApplicationController
      before_action :set_organization_from_subdomain, only: [:create]
      before_action :authenticate_user!, only: [:destroy]
      def create
        unless @organization
          render json: { error: "Organization not found" }, status: :not_found
          return
        end

        user = @organization.users.find_by(email: params[:email])
        if user&.authenticate(params[:password])
          # Ensure auth_token is set correctly, if not already
          user.update!(auth_token: SecureRandom.hex(20)) if user.auth_token.blank?

          render json: {
            message: "Login successful",
            auth_token: user.auth_token,
            user: {
              id: user.id,
              email: user.email,
              name: user.name,
              role: user.role,
              organization_id: user.organization_id,
              team_id: user.team_id
            }
          }, status: :ok
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      # def destroy
      #   if current_user
      #     current_user.update!(auth_token: nil)
      #     render json: { message: "Logout successful" }, status: :ok
      #   else
      #     render json: { error: "Not logged in" }, status: :unauthorized
      #   end
      # end

      def destroy
        token = request.headers['Authorization']&.split(' ')&.last
        user = User.find_by(auth_token: token)

        if user
          user.update(auth_token: nil)
          render json: { message: "Logged out successfully" }, status: :ok
        else
          render json: { error: "Invalid token" }, status: :unauthorized
        end
      end

      def verify
        if current_user
          render json: { message: "Token valid", role: current_user.role }, status: :ok
        else
          render json: { error: "Invalid token" }, status: :unauthorized
        end
      end

      def verify_admin
        head current_user&.admin? ? :ok : :forbidden
      end

      private

      def current_user
        # Extract the token from the Authorization header, strip 'Bearer ' part
        token = request.headers['Authorization']&.split(' ')&.last
        @current_user ||= User.find_by(auth_token: token)
      end
    end
  end
end
