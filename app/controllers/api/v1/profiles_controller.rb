module Api
  module V1
    class ProfilesController < Api::V1::ApiController
      before_action :set_organization_from_subdomain
      before_action :authenticate_user!

      include Rails.application.routes.url_helpers
      

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
        user.as_json(only: [
          :id, :email, :name, :username, :role, :position,
          :phone_number, :department_id, :team_id, :organization_id,
          :is_admin, :team_ids
        ]).merge({
          profile_picture_url: user.profile_picture.attached? ? url_for(user.profile_picture) : nil
        })
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