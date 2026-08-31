class CreatePhotos < ActiveRecord::Migration[ 8.1 ]
  def up
    create_table :photos do |t|
      t.references :album, null: false, foreign_key: true
      t.integer :position, null: false

      t.datetime :taken_at
      t.boolean :taken_at_overridden, default: false, null: false

      t.string :author
      t.boolean :author_overridden, default: false, null: false

      t.string :place
      t.boolean :place_overridden, default: false, null: false
      t.decimal :latitude, precision: 9, scale: 6
      t.decimal :longitude, precision: 9, scale: 6

      t.string :camera
      t.boolean :camera_overridden, default: false, null: false

      t.string :lens
      t.boolean :lens_overridden, default: false, null: false

      t.timestamps
    end
    add_index :photos, %i[ album_id position ], unique: true

    backfill_photos_from_existing_attachments
  end

  def down
    drop_table :photos
  end

  private
    # every existing album_photos attachment becomes a real Photo row, in the same order it already
    # displayed in, pointing at the same blob rather than duplicating the file — otherwise both
    # albums that exist today lose their photos the moment this migrates, since Album stops reading
    # has_many_attached :photos the moment Photo exists
    def backfill_photos_from_existing_attachments
      attachments = ActiveStorage::Attachment.where( record_type: "Album", name: "photos" ).order( :id )
      attachments.group_by( &:record_id ).each do |album_id, album_attachments|
        album_attachments.each_with_index do |attachment, index|
          photo = Photo.create!( album_id: album_id, position: index )
          photo.image.attach( attachment.blob )
          photo.refresh_from_exif!
        end
        Album.find( album_id ).refresh_captured_period!
      end
    end
end

#	20260820190428_create_photos.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
