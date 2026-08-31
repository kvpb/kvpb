class RenameSuperuserToAdminOnUsers < ActiveRecord::Migration[ 8.1 ]
  def change
    rename_column :users, :superuser, :admin
  end
end
