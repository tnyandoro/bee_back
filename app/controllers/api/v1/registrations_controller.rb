# app/controllers/api/v1/registrations_controller.rb
module Api
    module V1
      class RegistrationsController < ApplicationController
        skip_before_action :authenticate_user!, only: [:create]
  
        def create
          ActiveRecord::Base.transaction do
            Rails.logger.debug "Organization params: #{organization_params.inspect}"
            @organization = Organization.new(organization_params)
            @organization.save!
  
            Rails.logger.debug "Admin params: #{admin_params.inspect}"
            @admin = @organization.users.new(admin_params)
            @admin.role = :admin
            @admin.auth_token = SecureRandom.hex(20)
            @admin.save!
  
            render json: {
              message: "Organization and admin registered successfully",
              organization: {
                id: @organization.id,
                name: @organization.name,
                subdomain: @organization.subdomain
              },
              admin: {
                id: @admin.id,
                name: @admin.name,
                email: @admin.email,
                role: @admin.role,
                auth_token: @admin.auth_token
              }
            }, status: :created
          rescue ActiveRecord::RecordInvalid => e
            render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
          rescue StandardError => e
            Rails.logger.error "Registration error: #{e.message}"
            render json: { error: e.message }, status: :unprocessable_entity
          end
        end
  
        private
  
        def organization_params
          # Map 'website' to 'web_address'
          org_params = params.require(:organization).permit(:name, :email, :phone_number, :website, :address, :subdomain)
          org_params[:web_address] = org_params.delete(:website) if org_params[:website]
          org_params
        end
  
        def admin_params
          params.require(:admin).permit(:name, :email, :phone_number, :password, :password_confirmation, :department, :position, :username)
        end
      end
    end
  end
  