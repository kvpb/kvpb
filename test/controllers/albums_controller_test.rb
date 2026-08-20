require "test_helper"

class AlbumsControllerTest < ActionDispatch::IntegrationTest
  test "index lists only published albums for guests" do
    published = Album.create!( title: "Published", published_at: 1.day.ago )
    draft = Album.create!( title: "Draft" )

    get see_path

    assert_response :success
    assert_match published.title, response.body
    assert_no_match draft.title, response.body
  end

  test "index lists drafts too for a signed-in superuser" do
    draft = Album.create!( title: "Draft" )
    sign_in_as( users( :one ) )

    get see_path

    assert_match draft.title, response.body
  end

  test "index redirects guests to root when the gallery is empty" do
    get see_path

    assert_redirected_to root_path
  end

  test "index still renders for a signed-in superuser when the gallery is empty" do
    sign_in_as( users( :one ) )

    get see_path

    assert_response :success
  end

  test "show renders a published album for guests" do
    album = Album.create!( title: "Published", published_at: 1.day.ago )
    get album_path( album )
    assert_response :success
  end

  test "show 404s a draft for guests" do
    album = Album.create!( title: "Draft" )
    get album_path( album )
    assert_response :not_found
  end

  test "new requires a signed-in superuser" do
    get new_album_path
    assert_redirected_to new_session_path( token: login_token )

    sign_in_as( users( :two ) )
    get new_album_path
    assert_redirected_to root_path
  end

  test "create requires a signed-in superuser" do
    assert_no_difference( "Album.count" ) do
      post see_path, params: { album: { title: "Someone's trip" } }
    end
  end

  test "create builds a draft album by default" do
    sign_in_as( users( :one ) )

    assert_difference( "Album.count", 1 ) do
      post see_path, params: { album: { title: "New Trip" } }
    end

    assert_not Album.find_by!( identifier: "new-trip" ).published?
  end

  test "update lets a superuser publish" do
    sign_in_as( users( :one ) )
    album = Album.create!( title: "Draft" )

    patch album_path( album ), params: { album: { published_at: Time.current } }

    assert album.reload.published?
  end

  test "update without new photos leaves existing photos untouched" do
    sign_in_as( users( :one ) )
    album = Album.create!( title: "With Photos" )
    album.photos.attach( io: StringIO.new( "fake" ), filename: "a.jpg", content_type: "image/jpeg" )

    patch album_path( album ), params: { album: { title: "Renamed" } }

    assert_equal 1, album.reload.photos.count
    assert_equal "Renamed", album.title
  end

  test "update with new photos adds to the existing set" do
    sign_in_as( users( :one ) )
    album = Album.create!( title: "With Photos" )
    album.photos.attach( io: StringIO.new( "fake" ), filename: "a.jpg", content_type: "image/jpeg" )

    patch album_path( album ), params: { album: { photos: [ fixture_file_upload( "test/fixtures/files/sample.jpg", "image/jpeg" ) ] } }

    assert_equal 2, album.reload.photos.count
  end

  test "create derives the captured period from the uploaded photos' own EXIF" do
    sign_in_as( users( :one ) )

    post see_path, params: { album: { title: "EXIF Trip", photos: [
      fixture_file_upload( "test/fixtures/files/sample_early.jpg", "image/jpeg" ),
      fixture_file_upload( "test/fixtures/files/sample_late.jpg", "image/jpeg" )
    ] } }

    album = Album.find_by!( identifier: "exif-trip" )
    assert_equal Date.new( 2024, 3, 15 ), album.taken_from
    assert_equal Date.new( 2024, 8, 22 ), album.taken_until
  end

  test "update recomputes the captured period once new photos are attached" do
    sign_in_as( users( :one ) )
    album = Album.create!( title: "Growing Trip" )
    album.photos.attach( io: File.open( file_fixture( "sample_early.jpg" ) ), filename: "early.jpg", content_type: "image/jpeg" )
    album.refresh_captured_period!

    patch album_path( album ), params: { album: { photos: [ fixture_file_upload( "test/fixtures/files/sample_late.jpg", "image/jpeg" ) ] } }

    assert_equal Date.new( 2024, 3, 15 ), album.reload.taken_from
    assert_equal Date.new( 2024, 8, 22 ), album.taken_until
  end

  test "destroy requires a signed-in superuser" do
    album = Album.create!( title: "Published", published_at: 1.day.ago )
    assert_no_difference( "Album.count" ) do
      delete album_path( album )
    end
  end
end

#	albums_controller_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
