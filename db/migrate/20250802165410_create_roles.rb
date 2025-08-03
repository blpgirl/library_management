class CreateRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.boolean :is_active, default: true

      t.timestamps
    end
    
    add_index :roles, :name, unique: true
  end
end
