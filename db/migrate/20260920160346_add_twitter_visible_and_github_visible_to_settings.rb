class AddTwitterVisibleAndGithubVisibleToSettings < ActiveRecord::Migration[ 8.1 ]
  def change
    add_column :settings, :twitter_visible, :boolean, null: false, default: false
    add_column :settings, :github_visible, :boolean, null: false, default: true
  end
end
