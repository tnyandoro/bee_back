# app/controllers/api/v1/registrations_controller.rb
module Api
    module V1
      class RegistrationsController < ApplicationController
        skip_before_action :authenticate_user!, only: [:create] # No auth required for registration
  
        def create
          ActiveRecord::Base.transaction do
            # Create the organization
            @organization = Organization.new(organization_params)
            unless @organization.save
              render json: { errors: @organization.errors.full_messages }, status: :unprocessable_entity
              return
            end
  
            # Create the admin user for the organization
            @admin = @organization.users.new(admin_params)
            @admin.role = :admin # Force admin role for initial registration
            @admin.auth_token = SecureRandom.hex(20) # Generate token immediately
  
            unless @admin.save
              render json: { errors: @admin.errors.full_messages }, status: :unprocessable_entity
              return
            end
  
            # Success response with organization, admin, and token
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
          rescue StandardError => e
            render json: { error: e.message }, status: :unprocessable_entity
          end
        end
  
        private
  
        def organization_params
          params.require(:organization).permit(:name, :email, :phone_number, :website, :address, :subdomain)
        end
  
        def admin_params
          params.require(:admin).permit(:name, :email, :phone_number, :password, :password_confirmation, :department, :position, :username)
        end
      end
    end
  end