require "test_helper"

class PrintsControllerTest < ActionDispatch::IntegrationTest
  test "show renders a published print for guests" do
    print = create_print!( published_at: 1.day.ago )
    get print_path( print )
    assert_response :success
  end

  test "show 404s a draft for guests, but renders it for a signed-in admin" do
    print = create_print!

    get print_path( print )
    assert_response :not_found

    sign_in_as( users( :one ) )
    get print_path( print )
    assert_response :success
  end

  test "new requires a signed-in admin" do
    get new_print_path
    assert_redirected_to root_path

    sign_in_as( users( :two ) )
    get new_print_path
    assert_redirected_to root_path
  end

  test "create requires a signed-in admin" do
    assert_no_difference( "Print.count" ) do
      post backend_prints_path, params: { print: { title: "A Photo", image: fixture_file_upload( "test/fixtures/files/sample.jpg", "image/jpeg" ) } }
    end
  end

  test "create builds a draft print by default" do
    sign_in_as( users( :one ) )

    assert_difference( "Print.count", 1 ) do
      post backend_prints_path, params: { print: { title: "A Photo", image: fixture_file_upload( "test/fixtures/files/sample.jpg", "image/jpeg" ) } }
    end

    assert_not Print.order( :created_at ).last.published?
  end

  test "update lets an admin publish, and replace the photo without needing a new one" do
    sign_in_as( users( :one ) )
    print = create_print!

    patch backend_print_path( print ), params: { print: { published_at: Time.current } }
    assert print.reload.published?

    patch backend_print_path( print ), params: { print: { title: "Renamed" } }
    assert_equal "Renamed", print.reload.title
    assert print.image.attached?
  end

  test "destroy requires a signed-in admin" do
    print = create_print!( published_at: 1.day.ago )
    assert_no_difference( "Print.count" ) do
      delete backend_print_path( print )
    end

    sign_in_as( users( :one ) )
    assert_difference( "Print.count", -1 ) do
      delete backend_print_path( print )
    end
  end

  test "a HEIC print is shown through the JPEG made of it, never as the HEIC itself" do
    print = create_print!( fixture_filename: "sample_full_exif.heic", filename: "IMG_0001.HEIC", content_type: "image/heic", published_at: 1.day.ago )
    skip "ImageMagick can't read a HEIC on this machine" if print.exif[ :camera ].blank?

    get print_path( print )

    assert_response :success
    assert_select "img.print_image[src*='/representations/']", count: 1
    assert_select "img.print_image[src*='/blobs/']", count: 0
    assert_equal "IMG_0001.HEIC", print.image.filename.to_s
  end

  private
    def create_print!( fixture_filename: "sample.jpg", filename: fixture_filename, content_type: "image/jpeg", published_at: nil )
      print = Print.new( title: "Test Print", published_at: published_at )
      print.image.attach( io: File.open( file_fixture( fixture_filename ) ), filename: filename, content_type: content_type )
      print.save!
      print
    end
end

#	prints_controller_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
