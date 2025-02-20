# frozen_string_literal: true
module Api
  module V1
    class SessionsController < ApplicationController
      skip_before_action :verify_authenticity_token # For API usage
      before_action :set_organization_from_subdomain, only: [:create]

      def create
        unless @organization
          render json: { error: "Organization not found" }, status: :not_found
          return
        end

        user = @organization.users.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          # Generate or update auth token
          user.update(auth_token: SecureRandom.hex(20)) unless user.auth_token

          # Prepare response data
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
        # Assuming you have a current_user method from authentication
        if current_user
          current_user.update(auth_token: nil)
          render json: { message: "Logout successful" }, status: :ok
        else
          render json: { error: "Not logged in" }, status: :unauthorized
        end
      end

      private

      def set_organization_from_subdomain
        subdomain = request.subdomain.presence || params[:subdomain]
        @organization = Organization.find_by(subdomain: subdomain)
      end
    end
  end
end