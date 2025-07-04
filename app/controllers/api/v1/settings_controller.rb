module Api
    module V1
      class SettingsController < ApplicationController
        before_action :authenticate_api_user!
        before_action :set_organization
  
        def index
          settings = @organization.settings.map { |s| [s.key, s.value] }.to_h
          render json: settings
        end
  
        def update
          setting = @organization.settings.find_or_initialize_by(key: params[:key])
          setting.value = params[:value]
          if setting.save
            render json: setting
          else
            render json: { error: setting.errors.full_messages }, status: :unprocessable_entity
          end
        end
  
        private
  
        def set_organization
          subdomain = params[:organization_subdomain] || params[:subdomain]
          @organization = Organization.find_by(subdomain: subdomain)
          render json: { error: "Organization not found" }, status: 404 unless @organization
        end
      end
    end
end
