module Api
  module V1
    class ProfilesController < ApplicationController
      before_action :set_organization_from_subdomain
      before_action :authenticate_user!

      def show
        user = current_user

        unless user && user.organization_id == @organization.id
          return render_unauthorized("Invalid user or organization")
        end

        render json: {
          user: user_profile_json(user),
          organization: organization_profile_json(@organization)
        }, status: :ok
      end

      private

      def user_profile_json(user)
        {
          id: user.id,
          email: user.email,
          name: user.name,
          username: user.username,
          position: user.position,
          role: user.role,
          is_admin: user.is_admin?,
          team_id: user.team_id, # Already included, no change needed
          team_ids: user.team_id ? [user.team_id] : [], # Return team_id as an array for backward compatibility
          department_id: user.department_id,
          organization_id: user.organization_id
        }
      end

      def organization_profile_json(org)
        {
          id: org.id,
          name: org.name,
          subdomain: org.subdomain,
          web_address: org.web_address,
          phone_number: org.phone_number
        }
      end
    end
  end
end