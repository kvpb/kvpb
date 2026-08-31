require "test_helper"

class PivotPhotoTest < ActionDispatch::IntegrationTest
  test "the main page carries the easter egg's photograph, not yet loaded, on the controller that swings it in" do
    get root_path

    assert_select "#pivot_photo[data-controller='pivot-photo'][data-pivot-photo-src-value*='EB145906']", count: 1
    assert_select "#pivot_photo #pivot_photo_swing[data-pivot-photo-target='swing'] img#pivot_photo_image[data-pivot-photo-target='image']", count: 1
    assert_select "#pivot_photo_image[src]", count: 0
    assert_select "#pivot_photo_image[data-controller~='squircle-clip']", count: 0
  end

  test "so does every other page, and it needs no profile photo to be shown" do
    sign_in_as( users( :one ) )

    [ see_path, read_path ].each do |path|
      get path

      assert_select "#pivot_photo[data-controller='pivot-photo']", count: 1
    end
  end

  test "the photograph it swings in is an asset the page can actually fetch" do
    get root_path

    src = css_select( "#pivot_photo" ).first[ "data-pivot-photo-src-value" ]
    get src

    assert_response :success
    assert_equal "image/png", response.media_type
  end
end

#	pivot_photo_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
