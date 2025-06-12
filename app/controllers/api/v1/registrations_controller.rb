module Api
  module V1
    class RegistrationsController < ApplicationController
      skip_before_action :authenticate_user!, only: [:create]
      skip_before_action :set_organization_from_subdomain, only: [:create]
      rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error

      def create
        ActiveRecord::Base.transaction do
          # Validate subdomain first
          validate_subdomain_availability!
          
          organization = Organization.new(organization_params)
          organization.save!

          # admin = organization.users.new(admin_params.except(:department))
          admin = organization.users.new(admin_params.except(:department, :department_id))
          admin.role = :domain_admin # Changed from :admin
          admin.auth_token = generate_auth_token
          admin.save!

          render_success_response(organization, admin)
        end
      rescue StandardError => e
        handle_registration_error(e)
      end

      private

      def validate_subdomain_availability!
        if Organization.exists?(subdomain: params[:organization][:subdomain].downcase)
          raise ActiveRecord::RecordInvalid.new(
            Organization.new.tap { |o| o.errors.add(:subdomain, 'has already been taken') }
          )
        end
      end

      def generate_auth_token
        loop do
          token = SecureRandom.hex(20)
          break token unless User.exists?(auth_token: token)
        end
      end

      def organization_params
        params.require(:organization).permit(
          :name, :email, :phone_number, :address, :subdomain, :website
        ).tap do |p|
          p[:web_address] = p.delete(:website) if p[:website]
          p[:subdomain] = p[:subdomain].downcase
        end
      end

      def admin_params
        params.require(:admin).permit(
          :password_confirmation, :department_id, 
          :position, :username
        ).tap do |p|
          p[:email] = p[:email].downcase
        end
      end

      def render_success_response(organization, admin)
        render json: {
          message: "Registration successful",
          organization: organization.as_json(only: [:id, :name, :subdomain]),
          admin: admin.as_json(
            only: [:id, :name, :email, :username],
            methods: [:auth_token]
          )
        }, status: :created
      end

      def handle_validation_error(exception)
        render json: { 
          error: "Validation failed",
          details: exception.record.errors.messages 
        }, status: :unprocessable_entity
      end

      def handle_registration_error(exception)
        Rails.logger.error "Registration Error: #{exception.message}\n#{exception.backtrace.join("\n")}"
        
        error_message = if exception.is_a?(ActiveRecord::RecordInvalid)
                         exception.record.errors.full_messages.to_sentence
                       else
                         "Registration failed. Please try again."
                       end

        render json: { 
          error: error_message 
        }, status: :unprocessable_entity
      end
    end
  end
end