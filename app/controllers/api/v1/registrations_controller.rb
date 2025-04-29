module Api
  module V1
    class RegistrationsController < ApplicationController
      skip_before_action :authenticate_user!, only: [:create]
      rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error

      def create
        ActiveRecord::Base.transaction do
          organization = Organization.new(organization_params)
          organization.save!

          admin = organization.users.new(admin_params)
          admin.role = :admin
          admin.auth_token = SecureRandom.hex(20)
          admin.save!

          render_success_response(organization, admin)
        end
      rescue StandardError => e
        handle_registration_error(e)
      end

      private

      def organization_params
        params.require(:organization).permit(
          :name, :email, :phone_number, :address, :subdomain, :website
        ).tap do |p|
          p[:web_address] = p.delete(:website) if p[:website]
        end
      end

      def admin_params
        params.require(:admin).permit(
          :name, :email, :phone_number, :password, 
          :password_confirmation, :department, 
          :position, :username
        )
      end

      def render_success_response(organization, admin)
        render json: {
          message: "Registration successful",
          organization: organization.as_json(only: [:id, :name, :subdomain]),
          admin: admin.as_json(only: [:id, :name, :email]).merge(auth_token: admin.auth_token)
        }, status: :created
      end

      def handle_validation_error(exception)
        render json: { errors: exception.record.errors.full_messages }, 
               status: :unprocessable_entity
      end

      def handle_registration_error(exception)
        Rails.logger.error "Registration Error: #{exception.message}\n#{exception.backtrace.join("\n")}"
        render json: { error: "Registration failed: #{exception.message}" }, 
               status: :unprocessable_entity
      end
    end
  end
end