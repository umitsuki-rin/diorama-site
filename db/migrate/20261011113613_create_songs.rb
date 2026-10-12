class CreateSongs < ActiveRecord::Migration[8.1]
  def change
    create_table :songs do |t|
      t.string :title, null: false
      t.text :description
      t.date :released_on
      t.string :youtube_url
      t.string :niconico_url
      t.string :apple_music_url
      t.string :amazon_music_url
      t.string :awa_url
      t.string :spotify_url
      t.integer :status, null: false, default: 0

      t.timestamps
    end
    add_index :songs, [ :status, :created_at ]
  end
end
