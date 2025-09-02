module Api
  module V1
    class SettingsController < Api::V1::ApiController

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
          return render_error(message: ErrorCodes::Messages::MISSING_KEY_OR_VALUE, error_code: ErrorCodes::Codes::MISSING_KEY_OR_VALUE, status: :bad_request)
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
          render_error(errors: setting.full_messages, message: ErrorCodes::Messages::FAILED_TO_SAVE_SETTING, error_code: ErrorCodes::Codes::FAILED_TO_SAVE_SETTING, status: :unprocessable_entity)
        end
      end

      private

      def set_organization
        subdomain = params[:organization_subdomain] || params[:subdomain]
        @organization = Organization.find_by(subdomain: subdomain)
        render_error(message: ErrorCodes::Messages::ORGANIZATION_NOT_FOUND_FOR_SUBDOMAIN, error_code: ErrorCodes::Codes::ORGANIZATION_NOT_FOUND_FOR_SUBDOMAIN, status: :not_found) unless @organization
      end
    end
  end
end
