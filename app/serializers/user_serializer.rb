# frozen_string_literal: true
class UserSerializer
    include JSONAPI::Serializer
  
    attributes :id, :name, :email, :role, :department, :position, :created_at, :updated_at
  
    belongs_to :organization, serializer: OrganizationSerializer
    belongs_to :team, serializer: TeamSerializer
  end
