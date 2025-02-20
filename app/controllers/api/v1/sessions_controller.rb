# app/controllers/api/v1/sessions_controller.rb
module Api
  module V1
    class SessionsController < ApplicationController
      # Skip authentication for login, rely on ApplicationController's except: [:create]
      before_action :set_organization_from_subdomain, only: [:create]

      def create
        unless @organization
          render json: { error: "Organization not found" }, status: :not_found
          return
        end

        user = @organization.users.find_by(email: params[:email])
        if user&.authenticate(params[:password])
          # Ensure token is unique and regenerated on each login
          user.update!(auth_token: SecureRandom.hex(20))
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

      def destroy
        if current_user
          current_user.update!(auth_token: nil)
          render json: { message: "Logout successful" }, status: :ok
        else
          render json: { error: "Not logged in" }, status: :unauthorized
        end
      end

      # Note: set_organization_from_subdomain is defined in ApplicationController
    end
  end
end
