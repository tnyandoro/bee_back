module Api
  module V1
    class PasswordsController < ApplicationController
      skip_before_action :authenticate_user!
      skip_before_action :verify_user_organization
      skip_before_action :set_organization_from_subdomain

      def reset
        subdomain = params[:subdomain]&.downcase
        organization = Organization.find_by("LOWER(subdomain) = ?", subdomain)

        unless organization
          return render json: { error: "Organization not found" }, status: :not_found
        end

        user = organization.users.find_by(email: params[:email]&.downcase)
        unless user
          return render json: { error: "Email not found" }, status: :not_found
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
        render json: { error: "Server error: #{e.message}" }, status: :unprocessable_entity
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
          return render json: { error: "Password and confirmation are required" }, status: :unprocessable_entity
        end

        if params[:password] != params[:password_confirmation]
          return render json: { error: "Passwords do not match" }, status: :unprocessable_entity
        end

        if params[:password].length < 6
          return render json: { error: "Password must be at least 6 characters" }, status: :unprocessable_entity
        end

        user.update!(
          password: params[:password],
          reset_password_token: nil,
          reset_password_sent_at: nil
        )

        render json: { message: "Password updated successfully" }, status: :ok
      rescue => e
        Rails.logger.error "Password update error: #{e.message}"
        render json: { error: "Server error: #{e.message}" }, status: :unprocessable_entity
      end
    end
  end
end
