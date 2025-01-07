class UserSerializer
    include JSONAPI::Serializer
  
    attributes :id, :name, :email, :role, :department, :position
end