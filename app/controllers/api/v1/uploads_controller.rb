module Api
    module V1
      class UploadsController < ApplicationController
        before_action :authenticate_user!
        before_action :set_organization, only: [:upload_logo]
  
        def upload_profile_picture
          if current_user.update(profile_picture: params[:file])
            render json: { url: url_for(current_user.profile_picture) }
          else
            render json: { error: "Upload failed" }, status: :unprocessable_entity
          end
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
