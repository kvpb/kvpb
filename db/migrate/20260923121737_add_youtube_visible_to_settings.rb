class AddYoutubeVisibleToSettings < ActiveRecord::Migration[ 8.1 ]
  def change
    add_column :settings, :youtube_visible, :boolean, null: false, default: false
  end
end
