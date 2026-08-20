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
    attach_photo!( album, io: StringIO.new( "fake" ), filename: "a.jpg" )

    assert_equal "a.jpg", album.cover.filename.to_s
  end

  test "cover prefers an explicit cover photo over the first photo" do
    album = Album.create!( title: "With Cover" )
    attach_photo!( album, io: StringIO.new( "fake" ), filename: "a.jpg" )
    album.cover_photo.attach( io: StringIO.new( "fake" ), filename: "cover.jpg", content_type: "image/jpeg" )

    assert_equal "cover.jpg", album.cover.filename.to_s
  end

  test "cover is nil when there are no photos at all" do
    album = Album.create!( title: "Empty" )
    assert_nil album.cover
  end

  test "refresh_captured_period! spans from the oldest photo's EXIF date to the most recent" do
    album = Album.create!( title: "With EXIF Photos" )
    attach_photo!( album, io: File.open( file_fixture( "sample_late.jpg" ) ), filename: "late.jpg" )
    attach_photo!( album, io: File.open( file_fixture( "sample_early.jpg" ) ), filename: "early.jpg" )

    album.refresh_captured_period!

    assert_equal Date.new( 2024, 3, 15 ), album.taken_from
    assert_equal Date.new( 2024, 8, 22 ), album.taken_until
  end

  test "refresh_captured_period! ignores photos with no readable EXIF date" do
    album = Album.create!( title: "Mixed Photos" )
    attach_photo!( album, io: File.open( file_fixture( "sample_late.jpg" ) ), filename: "late.jpg" )
    attach_photo!( album, io: File.open( file_fixture( "sample.jpg" ) ), filename: "no-exif.jpg" )

    album.refresh_captured_period!

    assert_equal Date.new( 2024, 8, 22 ), album.taken_from
    assert_equal Date.new( 2024, 8, 22 ), album.taken_until
  end

  test "refresh_captured_period! leaves the period blank when no photo has a readable date" do
    album = Album.create!( title: "No EXIF" )
    attach_photo!( album, io: StringIO.new( "fake" ), filename: "a.jpg" )

    album.refresh_captured_period!

    assert_nil album.taken_from
    assert_nil album.taken_until
  end

  test "captured_period_label collapses to one month when the span doesn't cross a month" do
    album = Album.create!( title: "Same Month", taken_from: Date.new( 2024, 3, 5 ), taken_until: Date.new( 2024, 3, 20 ) )
    assert_equal "March 2024", album.captured_period_label
  end

  test "captured_period_label spans months within the same year" do
    album = Album.create!( title: "Same Year", taken_from: Date.new( 2024, 3, 15 ), taken_until: Date.new( 2024, 8, 22 ) )
    assert_equal "March – August 2024", album.captured_period_label
  end

  test "captured_period_label spans years" do
    album = Album.create!( title: "Across Years", taken_from: Date.new( 2023, 12, 1 ), taken_until: Date.new( 2024, 3, 1 ) )
    assert_equal "December 2023 – March 2024", album.captured_period_label
  end

  test "captured_period_label is blank when the period isn't set" do
    album = Album.create!( title: "Undated" )
    assert_nil album.captured_period_label
  end

  private
    def attach_photo!( album, io:, filename: )
      photo = album.photos.create!( position: album.photos.maximum( :position ).to_i + 1 )
      photo.image.attach( io: io, filename: filename, content_type: "image/jpeg" )
      photo.refresh_from_exif!
      photo
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
