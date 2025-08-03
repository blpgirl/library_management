class BookSerializer < ActiveModel::Serializer
  attributes :id, :title, :isbn, :total_copies, :available_copies, :is_active
  # Include the author's name and genre's name in the serialized output
  attribute :author_name do
    object.author.name
  end
  attribute :genre_name do
    object.genre.name
  end
end