# frzen_string_literal: true
module Api
  module V1
    class UploadsController < Api::V1::ApiController
      require "open-uri"
      before_action :set_organization, only: [:upload_logo]

      # POST /api/v1/uploads/upload_profile_picture
      def upload_profile_picture
        file_url = params[:file]

        if file_url.blank?
          return render_error(message: ErrorCodes::Messages::NO_FILE_URL_PROVIDED, error_code: ErrorCodes::Codes::NO_FILE_URL_PROVIDED, status: :bad_request)
        end

        begin
          file = URI.open(file_url)

          current_user.profile_picture.attach(
            io: file,
            filename: "profile_picture_#{current_user.id}.jpg",
            content_type: "image/jpeg"
          )

          if current_user.save
            render json: {
              message: "Profile picture uploaded and saved successfully",
              url: url_for(current_user.profile_picture)
            }, status: :ok
          else
            render_error(message: ErrorCodes::Messages::FAILED_TO_SAVE_PROFILE_PICTURE, error_code: ErrorCodes::Codes::FAILED_TO_SAVE_PROFILE_PICTURE, status: :unprocessable_entity)
          end
        rescue => e
          Rails.logger.error "❌ Profile upload failed: #{e.message}"
          render_error(message: ErrorCodes::Messages::FAILED_TO_SAVE_PROFILE_PICTURE, error_code: ErrorCodes::Codes::FAILED_TO_SAVE_PROFILE_PICTURE, status: :unprocessable_entity)
        end
      end

      # POST /api/v1/organizations/:subdomain/upload_logo
      def upload_logo
        file = params[:file]

        if file.blank?
          return render_error(message: ErrorCodes::Messages::NO_FILE_UPLOADED, error_code: ErrorCodes::Codes::NO_FILE_UPLOADED, status: :bad_request)
        end

        begin
          result = Cloudinary::Uploader.upload(file.tempfile, folder: "itsm_logos/#{@organization.subdomain}")
          logo_url = result["secure_url"]

          setting = @organization.settings.find_or_initialize_by(key: "branding")
          setting.value ||= {}
          setting.value["logo_url"] = logo_url
          setting.save!

          render json: { url: logo_url }, status: :ok
        rescue => e
          Rails.logger.error "❌ Logo upload failed: #{e.message}"
          render_error(message: ErrorCodes::Messages::LOGO_UPLOAD_FAILED, error_code: ErrorCodes::Codes::LOGO_UPLOAD_FAILED, status: :internal_server_error)
        end
      end
    end
  end
end
