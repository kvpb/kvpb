class CreateAlbums < ActiveRecord::Migration[ 8.1 ]
  def change
    create_table :albums do |t|
      t.string :title, null: false
      t.string :location
      t.date :taken_on
      t.text :description
      t.string :identifier, null: false
      t.datetime :published_at

      t.timestamps
    end
    add_index :albums, :identifier, unique: true
    add_index :albums, :published_at
  end
end

#	20260817194805_create_albums.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
