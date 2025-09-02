module Api
  module V1
    class PasswordsController < Api::V1::ApiController

      def reset
        subdomain = params[:subdomain]&.downcase
        organization = Organization.find_by("LOWER(subdomain) = ?", subdomain)

        unless organization
          return render_error(message: ErrorCodes::Messages::ORGANIZATION_NOT_FOUND, error_code: ErrorCodes::Codes::ORGANIZATION_NOT_FOUND, status: :not_found)
        end

        user = organization.users.find_by(email: params[:email]&.downcase)
        unless user
          return render_error(message: ErrorCodes::Messages::USER_NOT_FOUND, error_code: ErrorCodes::Codes::USER_NOT_FOUND, status: :not_found)
        end

        raw_token = SecureRandom.hex(20)
        user.update!(
          reset_password_token: Digest::SHA256.hexdigest(raw_token),
          reset_password_sent_at: Time.current
        )

        begin
          PasswordResetMailer.reset_password(user, raw_token, subdomain).deliver_now
        rescue => e
          Rails.logger.error "Password reset email failed: #{e.message}"
        end

        render json: { message: "Password reset email sent" }, status: :ok
      rescue => e
        Rails.logger.error "Reset error: #{e.message}"
        render_error(errors: [e.message], message: ErrorCodes::Messages::PASSWORD_RESET_FAILED, error_code: ErrorCodes::Codes::PASSWORD_RESET_FAILED, status: :unprocessable_entity)
      end

      def update
        token = params[:token]
        user = User.find_by(
          reset_password_token: Digest::SHA256.hexdigest(token),
          reset_password_sent_at: 1.hour.ago..Time.current
        )

        unless user
          return render json: { error: "Invalid or expired token" }, status: :unprocessable_entity
        end

        if params[:password].blank? || params[:password_confirmation].blank?
          return render_error(message: ErrorCodes::Messages::PASSWORD_AND_CONF_REQUIRED, error_code: ErrorCodes::Codes::PASSWORD_AND_CONF_REQUIRED, status: :unprocessable_entity)
        end

        if params[:password] != params[:password_confirmation]
          return render_error(message: ErrorCodes::Messages::PASSWORDS_DO_NOT_MATCH, error_code: ErrorCodes::Codes::PASSWORDS_DO_NOT_MATCH, status: :unprocessable_entity)
        end

        if params[:password].length < 6
          return render_error(message: ErrorCodes::Messages::PASSWORD_NOT_LONG_ENOUGH, error_code: ErrorCodes::Codes::PASSWORD_NOT_LONG_ENOUGH, status: :unprocessable_entity)
        end

        user.update!(
          password: params[:password],
          reset_password_token: nil,
          reset_password_sent_at: nil
        )

        render json: { message: "Password updated successfully" }, status: :ok
      rescue => e
        Rails.logger.error "Password update error: #{e.message}"
        render_error(errors: [e.message], message: ErrorCodes::Messages::INTERNAL_SERVER_ERROR, error_code: ErrorCodes::Codes::INTERNAL_SERVER_ERROR, status: :unprocessable_entity)
      end
    end
  end
end
