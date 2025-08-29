module Api
  module V1
    class ProfilesController < ApiController
      before_action :authenticate_user!
      before_action :verify_user_organization
      before_action :set_cors_headers

      def show
        render json: {
          organization: {
            id: @organization.id,
            name: @organization.name,
            subdomain: @organization.subdomain,
            email: @organization.email,
            web_address: @organization.web_address,
            phone_number: @organization.phone_number,
            logo_url: @organization.logo_url
          },
          current_user: {
            id: current_user.id,
            full_name: current_user.full_name,
            name: current_user.name,
            email: current_user.email,
            username: current_user.username,
            phone_number: current_user.phone_number,
            position: current_user.position,
            department_id: current_user.department_id,
            team_id: current_user.team_id,
            role: current_user.role,
            organization_id: current_user.organization_id,
            organization_subdomain: @organization.subdomain,
            avatar_url: current_user.avatar_url
          }
        }, status: :ok
      end

      private

      def set_cors_headers
        origin = request.headers['Origin']
        allowed_origins = [
          'https://itsm-gss.netlify.app',
          'https://gsolve360.greensoftsolutions.net',
          'http://localhost:3000'
        ]
        allowed_origins << /\.greensoftsolutions\.net$/

        if origin.present? && allowed_origins.any? { |o| o.is_a?(Regexp) ? o.match?(origin) : o == origin }
          headers['Access-Control-Allow-Origin'] = origin
          headers['Access-Control-Allow-Credentials'] = 'true'
          headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD'
          headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type, X-Organization-Subdomain'
        end
      end
    end
  end
end