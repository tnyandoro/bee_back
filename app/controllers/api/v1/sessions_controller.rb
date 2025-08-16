module Api
  module V1
    class SessionsController < Api::V1::ApiController
      skip_before_action :authenticate_user!, only: [:create, :options, :refresh]
      before_action :set_cors_headers
      after_action :set_cors_headers # ensure headers are added to all responses

      # OPTIONS for CORS preflight
      def options
        Rails.logger.info "Handling OPTIONS request for /api/v1/login, origin=#{request.headers['Origin']}"
        head :ok
      end

      # Login
      def create
        Rails.logger.info "Login attempt: email=#{params[:email]}, subdomain=#{params[:subdomain]}, origin=#{request.headers['Origin']}"

        subdomain = params[:subdomain]&.downcase&.gsub(/[^a-z0-9-]/, "")
        unless @organization
          Rails.logger.warn "Organization not found for subdomain=#{subdomain}"
          render json: { error: "Organization not found" }, status: :not_found and return
        end

        user = @organization.users.find_by("LOWER(email) = ?", params[:email]&.downcase)
        unless user&.authenticate(params[:password])
          Rails.logger.warn "Login failed for email=#{params[:email]}"
          render json: { error: "Invalid email or password" }, status: :unauthorized and return
        end

        unless user.role.present? && User.roles.key?(user.role)
          Rails.logger.error "User #{user.id} has invalid role: #{user.role.inspect}"
          render json: { error: "User role is invalid or missing" }, status: :unprocessable_entity and return
        end

        # ✅ Generate JWT tokens
        access_exp = 24.hours.from_now.to_i
        refresh_exp = 7.days.from_now.to_i

        access_token = JwtService.encode({ user_id: user.id, org_id: @organization.id, exp: access_exp })
        refresh_token = JwtService.encode({ user_id: user.id, org_id: @organization.id, exp: refresh_exp, type: "refresh" })

        render json: {
          message: "Login successful",
          auth_token: access_token,
          refresh_token: refresh_token,
          exp: access_exp,
          user: {
            id: user.id,
            email: user.email,
            name: user.name,
            role: user.role,
            organization_id: user.organization_id,
            team_id: user.team_id,
            team_ids: user.team_id ? [user.team_id] : []
          },
          subdomain: subdomain,
          organization_id: @organization.id
        }, status: :ok
      end

      # Logout (JWT is stateless)
      def destroy
        Rails.logger.info "Logout requested (JWT is stateless, no server cleanup)"
        render json: { message: "Logged out successfully" }, status: :ok
      end

      # Verify token validity
      def verify
        if current_user
          Rails.logger.info "Token verified for user #{current_user.id}"
          render json: { message: "Token valid", role: current_user.role }, status: :ok
        else
          Rails.logger.warn "Token verification failed: Invalid token"
          render json: { error: "Invalid token" }, status: :unauthorized
        end
      end

      # Verify admin token
      def verify_admin
        if current_user&.is_admin?
          Rails.logger.info "Admin token verified for user #{current_user.id}"
          head :ok
        else
          Rails.logger.warn "Admin verification failed: User not admin or invalid token"
          head :forbidden
        end
      end

      # Refresh auth_token using refresh_token
      def refresh
        token = params[:refresh_token]
        payload = JwtService.decode(token)

        if payload && payload["type"] == "refresh" && payload["exp"] > Time.now.to_i
          new_exp = 24.hours.from_now.to_i
          new_token = JwtService.encode({ user_id: payload["user_id"], org_id: payload["org_id"], exp: new_exp })

          render json: { auth_token: new_token, exp: new_exp, message: "Token refreshed successfully" }, status: :ok
        else
          render json: { error: "Invalid or expired refresh token" }, status: :unauthorized
        end
      end

      private

      # CORS headers
      def set_cors_headers
        origin = request.headers['Origin']
        allowed_origins = [
          'https://itsm-gss.netlify.app',
          'https://gsolve360.greensoftsolutions.net',
          'http://localhost:3000'
        ]
        allowed_origins << /\.greensoftsolutions\.net$/  # regex for all subdomains

        if origin.present? && allowed_origins.any? { |o| o.is_a?(Regexp) ? o.match?(origin) : o == origin }
          headers['Access-Control-Allow-Origin'] = origin
          headers['Access-Control-Allow-Credentials'] = 'true'
          headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD'
          headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type, X-Organization-Subdomain'
        end
      end

      # Fetch current user from JWT
      def current_user
        token = request.headers['Authorization']&.split(' ')&.last
        return unless token

        payload = JwtService.decode(token)
        return unless payload && payload["exp"] > Time.now.to_i

        @current_user ||= User.find_by(id: payload["user_id"], organization_id: payload["org_id"])
      end
    end
  end
end
