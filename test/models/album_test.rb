require "test_helper"

class AlbumTest < ActiveSupport::TestCase
  test "assigns an identifier from the title when blank" do
    album = Album.create!( title: "A Trip Somewhere" )
    assert_equal "a-trip-somewhere", album.identifier
  end

  test "disambiguates identifiers that would otherwise collide" do
    Album.create!( title: "A Trip Somewhere" )
    other = Album.create!( title: "A Trip Somewhere" )
    assert_equal "a-trip-somewhere-2", other.identifier
  end

  test "to_param returns the identifier" do
    album = Album.create!( title: "A Trip Somewhere" )
    assert_equal album.identifier, album.to_param
  end

  test "published? reflects published_at" do
    published = Album.create!( title: "Published", published_at: 1.day.ago )
    draft = Album.create!( title: "Draft" )
    assert published.published?
    assert_not draft.published?
  end

  test "published scope excludes drafts and future-scheduled albums" do
    published = Album.create!( title: "Published", published_at: 1.day.ago )
    draft = Album.create!( title: "Draft" )
    scheduled = Album.create!( title: "Scheduled", published_at: 1.day.from_now )

    assert_includes Album.published, published
    assert_not_includes Album.published, draft
    assert_not_includes Album.published, scheduled
  end

  test "cover defaults to the first photo when no cover photo is attached" do
    album = Album.create!( title: "With Photos" )
    album.photos.attach( io: StringIO.new( "fake" ), filename: "a.jpg", content_type: "image/jpeg" )

    assert_equal album.photos.first.id, album.cover.id
  end

  test "cover prefers an explicit cover photo over the first photo" do
    album = Album.create!( title: "With Cover" )
    album.photos.attach( io: StringIO.new( "fake" ), filename: "a.jpg", content_type: "image/jpeg" )
    album.cover_photo.attach( io: StringIO.new( "fake" ), filename: "cover.jpg", content_type: "image/jpeg" )

    assert_equal "cover.jpg", album.cover.filename.to_s
  end

  test "cover is nil when there are no photos at all" do
    album = Album.create!( title: "Empty" )
    assert_nil album.cover
  end
end

#	album_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
