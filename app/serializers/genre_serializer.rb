class GenreSerializer < ActiveModel::Serializer
  attributes :id, :name, :is_active
end