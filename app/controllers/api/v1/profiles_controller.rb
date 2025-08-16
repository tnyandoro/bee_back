module Api
  module V1
    class ProfilesController < Api::V1::ApiController
      skip_before_action :authenticate_user!, only: [:show]
      before_action :set_cors_headers
      before_action :set_organization_from_subdomain

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
          current_user: current_user&.slice(:id, :name, :email, :role, :team_id)
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
