class CreateGenres < ActiveRecord::Migration[8.0]
  def change
    create_table :genres do |t|
      t.string :name, null: false
      t.boolean :is_active, default: true, null: false

      t.timestamps
    end

    add_index :genres, :name, unique: true
  end
end
