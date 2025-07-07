module Api
    module V1
      class UploadsController < ApplicationController

        require "open-uri"

        before_action :authenticate_user!
        before_action :set_organization, only: [:upload_logo]
  
        def upload_profile_picture
          file_url = params[:file]

          if file_url.blank?
            render json: { error: "No file URL provided" }, status: :bad_request
            return
          end

          file = URI.open(file_url)

          current_user.profile_picture.attach(
            io: file,
            filename: "profile_picture_#{current_user.id}.jpg",
            content_type: "image/jpeg"
          )

          render json: {
            message: "Profile picture uploaded and saved successfully",
            url: url_for(current_user.profile_picture)
          }
        rescue => e
          render json: { error: "Upload failed", details: e.message }, status: :unprocessable_entity
        end
        
        def upload_logo
          file = params[:file]
          if file.blank?
            render_error("No file uploaded", status: :bad_request) and return
          end
        
          result = Cloudinary::Uploader.upload(file.tempfile, folder: "itsm_logos/#{@organization.subdomain}")
          logo_url = result["secure_url"]
        
          setting = @organization.settings.find_or_initialize_by(key: "branding")
          setting.value ||= {}
          setting.value["logo_url"] = logo_url
          setting.save!
        
          render json: { url: logo_url }, status: :ok
        rescue => e
          render_error("Logo upload failed", details: e.message, status: :internal_server_error)
        end                
      end
    end
end
