class CreateSiteLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :site_links do |t|
      t.string :slug, null: false
      t.string :url, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :site_links, :slug, unique: true
    add_index :site_links, [:active, :slug]
  end
end
