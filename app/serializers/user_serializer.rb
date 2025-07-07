# frozen_string_literal: true
class UserSerializer
    include JSONAPI::Serializer
  
    attributes :id, :name, :email, :username, :phone_number, :department, :position, :role, :team_id, :profile_picture_url, :created_at, :updated_at
  
    belongs_to :organization, serializer: OrganizationSerializer
    belongs_to :team, serializer: TeamSerializer

    def profile_picture_url
      object.profile_picture.attached? ? Rails.application.routes.url_helpers.url_for(object.profile_picture) : nil
    end
end
