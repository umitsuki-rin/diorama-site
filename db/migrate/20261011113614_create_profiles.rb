class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.text :body
      t.text :price_table
      t.text :request_notes
      t.text :achievements
      t.string :x_url
      t.string :youtube_url
      t.string :niconico_url
      t.string :note_url

      t.timestamps
    end
  end
end
