class CreateUrls < ActiveRecord::Migration[7.0]
  def change
    create_table :urls do |t|
      t.string :original_url, null: false
      t.string :short_url, null: false

      t.timestamps
    end
    add_index :urls, :short_url, unique: true
  end
end
