class CreateMessages < ActiveRecord::Migration[ 8.1 ]
  def change
    create_table :messages do |t|
      t.string :name, null: false
      t.string :phone_number, null: false
      t.string :email_address, null: false
      t.text :body, null: false
      t.boolean :read, null: false, default: false

      t.timestamps
    end
  end
end
