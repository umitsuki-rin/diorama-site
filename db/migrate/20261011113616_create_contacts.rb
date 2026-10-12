class CreateContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :contacts do |t|
      t.string :company_name
      t.string :name, null: false
      t.string :email, null: false
      t.text :body, null: false
      t.boolean :responded, null: false, default: false

      t.timestamps
    end
    add_index :contacts, :created_at
  end
end
