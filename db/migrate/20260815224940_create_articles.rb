class CreateArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :articles do |t|
      t.string :kicker
      t.string :headline, null: false
      t.string :subheadline
      t.text :lede
      t.text :body, null: false
      t.string :identifier, null: false
      t.datetime :published_at
      t.boolean :comments_locked, null: false, default: false

      t.timestamps
    end
    add_index :articles, :identifier, unique: true
    add_index :articles, :published_at
  end
end
