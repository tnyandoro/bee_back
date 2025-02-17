# frozen_string_literal: true
class OrganizationSerializer
    include JSONAPI::Serializer
  
    attributes :id, :name, :subdomain, :created_at, :updated_at
  end