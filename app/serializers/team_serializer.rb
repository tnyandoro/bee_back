# app/serializers/team_serializer.rb
class TeamSerializer
  include JSONAPI::Serializer

  attributes :id, :name, :created_at, :updated_at
end
