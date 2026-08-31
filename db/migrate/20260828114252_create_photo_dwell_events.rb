class CreatePhotoDwellEvents < ActiveRecord::Migration[ 8.1 ]
  def change
    create_table :photo_dwell_events do |t|
      t.references :photo, null: false, foreign_key: true
      t.decimal :seconds, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
