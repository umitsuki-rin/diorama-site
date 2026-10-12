class CreateNews < ActiveRecord::Migration[8.1]
  def change
    create_table :news do |t|
      t.string :title, null: false
      t.text :body
      t.date :published_on, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end
    add_index :news, [ :status, :published_on ]
  end
end
