# This file defines the serializers for the API responses.
# app/serializers/user_serializer.rb
#
class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :role_name, :is_active
  
  def role_name
    object.role.name
  end
end