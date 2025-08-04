# frzen_string_literal: true
module Api
  module V1
    class UploadsController < ApiController
      require "open-uri"

      before_action :authenticate_user!
      before_action :set_organization, only: [:upload_logo]

      # POST /api/v1/uploads/upload_profile_picture
      def upload_profile_picture
        file_url = params[:file]

        if file_url.blank?
          return render json: { error: "No file URL provided" }, status: :bad_request
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
            render json: { error: "Failed to save profile picture" }, status: :unprocessable_entity
          end
        rescue => e
          Rails.logger.error "❌ Profile upload failed: #{e.message}"
          render json: { error: "Upload failed", details: e.message }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/organizations/:subdomain/upload_logo
      def upload_logo
        file = params[:file]

        if file.blank?
          return render_error("No file uploaded", status: :bad_request)
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
          render_error("Logo upload failed", details: e.message, status: :internal_server_error)
        end
      end
    end
  end
end
