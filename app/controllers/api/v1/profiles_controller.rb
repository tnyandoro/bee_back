module Api
  module V1
    class ProfilesController < ApplicationController
      before_action :set_organization_from_subdomain
      before_action :authenticate_user!

      def show
        return render_unauthorized unless current_user

        user = @organization.users.find_by(id: current_user.id)
        return render_not_found('User') unless user

        render json: {
          user: {
            id: user.id,
            email: user.email,
            name: user.name,
            role: user.role,
            is_admin: user.is_admin?,
            username: user.username,
            position: user.position,
            team_id: user.team_id
          },
          organization: {
            id: @organization.id,
            name: @organization.name,
            subdomain: @organization.subdomain
          }
        }, status: :ok
      end
    end
  end
end