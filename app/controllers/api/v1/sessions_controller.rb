module Api
  module V1
    class SessionsController < Api::V1::ApiController
      skip_before_action :authenticate_user!, only: [:create, :refresh]

      # ---------------------------
      # Login
      # ---------------------------
      def create
        Rails.logger.info "Login attempt: email=#{params[:email]}, subdomain=#{params[:subdomain]}, origin=#{request.headers['Origin']}"

        subdomain = params[:subdomain]&.downcase&.gsub(/[^a-z0-9-]/, "")
        unless @organization
          Rails.logger.warn "Organization not found for subdomain=#{subdomain}"
          render_error(message: ErrorCodes::Messages::ORGANIZATION_NOT_FOUND_FOR_SUBDOMAIN, error_code: ErrorCodes::Codes::ORGANIZATION_NOT_FOUND_FOR_SUBDOMAIN, status: :not_found)
          return
        end

        user = @organization.users.find_by("LOWER(email) = ?", params[:email]&.downcase)
        unless user&.authenticate(params[:password])
          Rails.logger.warn "Login failed for email=#{params[:email]}"
          render_error(message: ErrorCodes::Messages::INVALID_USERNAME_OR_PASSWORD, error_code: ErrorCodes::Codes::INVALID_USERNAME_OR_PASSWORD, status: :unauthorized)
          return
        end

        unless user.role.present? && User.roles.key?(user.role)
          Rails.logger.error "User #{user.id} has invalid role: #{user.role.inspect}"
          render_error(message: ErrorCodes::Messages::USER_ROLE_MISSING_OR_INVALID, error_code: ErrorCodes::Codes::USER_ROLE_MISSING_OR_INVALID, status: :unprocessable_entity)
          return
        end

        # Generate JWT tokens
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

      # ---------------------------
      # Logout (JWT is stateless)
      # ---------------------------
      def destroy
        Rails.logger.info "Logout requested (JWT is stateless, no server cleanup)"
        render json: { message: "Logged out successfully" }, status: :ok
      end

      # ---------------------------
      # Verify token validity
      # ---------------------------
      def verify
        if current_user
          Rails.logger.info "Token verified for user #{current_user.id}"
          render json: { message: "Token valid", role: current_user.role }, status: :ok
        else
          Rails.logger.warn "Token verification failed: Invalid token"
          render_error(message: ErrorCodes::Messages::INVALID_TOKEN, error_code: ErrorCodes::Codes::INVALID_TOKEN, status: :unauthorized)
        end
      end

      # ---------------------------
      # Verify admin token
      # ---------------------------
      def verify_admin
        if current_user&.is_admin?
          Rails.logger.info "Admin token verified for user #{current_user.id}"
          head :ok
        else
          Rails.logger.warn "Admin verification failed: User not admin or invalid token"
          head :forbidden
        end
      end

      # ---------------------------
      # Refresh auth_token using refresh_token
      # ---------------------------
      def refresh
        token = params[:refresh_token]
        payload = JwtService.decode(token)

        if payload && payload["type"] == "refresh" && payload["exp"] > Time.now.to_i
          new_exp = 24.hours.from_now.to_i
          new_token = JwtService.encode({ user_id: payload["user_id"], org_id: payload["org_id"], exp: new_exp })

          render json: { auth_token: new_token, exp: new_exp, message: "Token refreshed successfully" }, status: :ok
        else
          render_error(message: ErrorCodes::Messages::INVALID_OR_EXPIRED_REFRESH_TOKEN, error_code: ErrorCodes::Codes::INVALID_OR_EXPIRED_REFRESH_TOKEN, status: :unauthorized)
          return
        end
      end

      private

      # ---------------------------
      # Fetch current user from JWT
      # ---------------------------
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
