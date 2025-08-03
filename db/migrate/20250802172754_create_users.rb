class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :encrypted_password, null: false, default: ""
      t.references :role, null: false, foreign_key: true
      t.boolean :is_active, default: true

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
