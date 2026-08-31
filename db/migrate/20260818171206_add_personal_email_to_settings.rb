class AddPersonalEmailToSettings < ActiveRecord::Migration[ 8.1 ]
  def change
    add_column :settings, :personal_email, :string
  end
end
