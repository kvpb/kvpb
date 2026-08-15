class CreateSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :settings do |t|
      t.boolean :registration_enabled, null: false, default: false

      t.timestamps
    end
  end
end
