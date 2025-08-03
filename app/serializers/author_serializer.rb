class AuthorSerializer < ActiveModel::Serializer
  attributes :id, :name, :is_active
end