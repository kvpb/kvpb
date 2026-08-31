class CreatePassages < ActiveRecord::Migration[ 8.1 ]
  def change
    create_table :passages do |t|
      t.references :album, null: false, foreign_key: true
      t.integer :position, null: false
      t.string :heading
      t.text :body

      t.timestamps
    end

    # deliberately not unique, unlike photos' own [album_id, position] index: a passage shares its
    # position space with the photos rather than having one of its own, so several passages can sit
    # at the same position — all of them before the photo there, in the order they were written
    add_index :passages, [ :album_id, :position ]
  end
end
