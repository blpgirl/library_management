class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.references :author, null: false, foreign_key: true
      t.references :genre, null: false, foreign_key: true
      t.string :isbn, null: false
      t.integer :total_copies, null: false, default: 0
      t.integer :available_copies, null: false, default: 0
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end
    
    add_index :books, :isbn, unique: true
  end
end
