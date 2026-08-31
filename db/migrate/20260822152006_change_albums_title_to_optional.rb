class ChangeAlbumsTitleToOptional < ActiveRecord::Migration[ 8.1 ]
  def change
    change_column_null :albums, :title, true
  end
end
