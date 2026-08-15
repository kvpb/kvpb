class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :article, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :author_name
      t.string :author_email
      t.text :body, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
