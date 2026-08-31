require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "photo_tag hands a photograph to the squircle controller" do
    assert_includes photo_tag( "/photo.jpg", class: "album_photo" ), 'data-controller="squircle-clip"'
  end

  test "photo_tag adds to the controllers a photograph already has, and doesn't replace them" do
    html = photo_tag( "/photo.jpg", data: { controller: "dwell-tracker", dwell_tracker_photo_id_value: 3 } )

    assert_includes html, 'data-controller="dwell-tracker squircle-clip"'
    assert_includes html, 'data-dwell-tracker-photo-id-value="3"'
  end

  test "photo_tag keeps the other options of the image" do
    html = photo_tag( "/photo.jpg", class: "album_photo", draggable: false, data: { squircle_clip_radius_value: 10 } )

    assert_includes html, 'class="album_photo"'
    assert_includes html, 'draggable="false"'
    assert_includes html, 'data-squircle-clip-radius-value="10"'
  end
end

#	application_helper_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
