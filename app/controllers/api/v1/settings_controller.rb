module Api
  module V1
    class SettingsController < ApiController
      before_action :authenticate_user!
      before_action :set_organization

      # GET /api/v1/organizations/:subdomain/settings
      def index
        settings = @organization.settings.map { |s| [s.key, s.value] }.to_h
        render json: settings
      end

      # PUT /api/v1/organizations/:subdomain/settings
      def update
        key = params[:key]
        incoming_value = params[:value]

        if key.blank? || incoming_value.nil?
          return render_error("Missing key or value", status: :bad_request)
        end

        setting = @organization.settings.find_or_initialize_by(key: key)

        # Merge for nested hashes
        if setting.value.is_a?(Hash) && incoming_value.is_a?(ActionController::Parameters)
          setting.value = setting.value.merge(incoming_value.to_unsafe_h)
        else
          setting.value = incoming_value
        end

        if setting.save
          render json: setting
        else
          render_error(setting.errors.full_messages, status: :unprocessable_entity)
        end
      end

      private

      def set_organization
        subdomain = params[:organization_subdomain] || params[:subdomain]
        @organization = Organization.find_by(subdomain: subdomain)
        render_error("Organization not found", status: :not_found) unless @organization
      end
    end
  end
end
