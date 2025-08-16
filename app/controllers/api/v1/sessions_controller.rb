module Api
  module V1
    class SessionsController < Api::V1::ApiController
      skip_before_action :authenticate_user!, only: [:create, :options, :refresh]
      before_action :set_cors_headers

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
          render json: { error: "Organization not found" }, status: :not_found
          return
        end

        user = @organization.users.find_by("LOWER(email) = ?", params[:email]&.downcase)
        unless user&.authenticate(params[:password])
          Rails.logger.warn "Login failed for email=#{params[:email]}"
          render json: { error: "Invalid email or password" }, status: :unauthorized
          return
        end

        unless user.role.present? && User.roles.key?(user.role)
          Rails.logger.error "User #{user.id} has invalid role: #{user.role.inspect}"
          render json: { error: "User role is invalid or missing" }, status: :unprocessable_entity
          return
        end

        begin
          # Generate new tokens if blank or expired
          if user.auth_token.blank? || user.token_expires_at&.past?
            user.update!(
              auth_token: SecureRandom.hex(20),
              token_expires_at: 1.day.from_now,
              refresh_token: SecureRandom.hex(30),
              refresh_token_expires_at: 7.days.from_now
            )
          end
        rescue StandardError => e
          Rails.logger.error "Failed to generate tokens for user #{user.id}: #{e.message}"
          render json: { error: "Failed to generate authentication token" }, status: :internal_server_error
          return
        end

        render json: {
          message: "Login successful",
          auth_token: user.auth_token,
          refresh_token: user.refresh_token,
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

      # Logout
      def destroy
        token = request.headers['Authorization']&.split(' ')&.last
        user = User.find_by(auth_token: token)

        if user
          user.update(auth_token: nil, token_expires_at: nil, refresh_token: nil, refresh_token_expires_at: nil)
          Rails.logger.info "User #{user.id} logged out successfully"
          render json: { message: "Logged out successfully" }, status: :ok
        else
          Rails.logger.warn "Logout failed: Invalid token"
          render json: { error: "Invalid token" }, status: :unauthorized
        end
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

      # Refresh auth_token using a valid refresh_token
      def refresh
        refresh_token = params[:refresh_token]
        user = User.find_by(refresh_token: refresh_token)

        if user && user.refresh_token_expires_at&.future?
          user.update!(
            auth_token: SecureRandom.hex(20),
            token_expires_at: 1.day.from_now
          )
          render json: { auth_token: user.auth_token, message: "Token refreshed successfully" }, status: :ok
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

        if allowed_origins.any? { |o| o.is_a?(Regexp) ? o.match?(origin) : o == origin }
          headers['Access-Control-Allow-Origin'] = origin
          headers['Access-Control-Allow-Credentials'] = 'true'
          headers['Access-Control-Allow-Methods'] = 'GET,POST,PUT,PATCH,DELETE,OPTIONS,HEAD'
          headers['Access-Control-Allow-Headers'] = 'Authorization,Content-Type,X-Organization-Subdomain'
        end
      end

      # Fetch current user from auth_token
      def current_user
        token = request.headers['Authorization']&.split(' ')&.last
        return unless token

        @current_user ||= User.find_by(auth_token: token)&.tap do |user|
          if user.token_expires_at&.past?
            user.update(auth_token: nil, token_expires_at: nil)
            Rails.logger.warn "Token expired for user #{user.id}"
          end
        end
      end
    end
  end
end
