require "test_helper"

class ShinyTest < ActionDispatch::IntegrationTest
  APNG = Rails.root.join( "app/assets/images/shiny_sparkles.png" )
  GIF = Rails.root.join( "app/assets/images/shiny_sparkles.gif" )

  test "every page carries the root of the sparkles, which does nothing until it draws its lot" do
    get root_path

    assert_select "#shiny[data-controller='shiny'][hidden]", count: 1
    assert_select "#shiny[data-shiny-sparkles-value*='shiny_sparkles'][data-shiny-fallback-value*='shiny_sparkles']", count: 1
  end

  test "both files the page names can actually be fetched, the APNG as a PNG and the GIF as a GIF" do
    get root_path
    apng = css_select( "#shiny" ).first[ "data-shiny-sparkles-value" ]
    gif = css_select( "#shiny" ).first[ "data-shiny-fallback-value" ]

    get apng
    assert_response :success
    assert_equal "image/png", response.media_type

    get gif
    assert_response :success
    assert_equal "image/gif", response.media_type
  end

  test "the APNG is the Game Boy's 48 frames, one every 70224 cycles of its 4194304 Hz clock, played for ever" do
    animation = apng_animation

    assert_equal 48, animation[ :frames ]
    assert_equal 0, animation[ :plays ], "0 plays is for ever"
    assert_equal 48, animation[ :delays ].size
    assert_equal [ [ 400, 23891 ] ], animation[ :delays ].uniq
    assert_in_delta 70224.0 / 4194304, 400.0 / 23891, 1e-9
    assert_in_delta 803.65, 48 * 1000.0 * 400 / 23891, 0.01
  end

  test "the GIF is the same 48 frames" do
    skip "ImageMagick can't be reached on this machine" unless system( "magick", "-version", out: File::NULL, err: File::NULL )

    frames = `magick identify -format "%w x %h\\n" #{ GIF }`.lines

    assert_equal 48, frames.size
    assert frames.all? { |frame| frame.strip == "48 x 48" }
  end

  private
    # The frame count, the number of plays and every frame's delay, read out of the APNG's own chunks
    def apng_animation
      data = File.binread( APNG )
      offset = 8
      animation = { delays: [] }
      while offset < data.bytesize
        length = data.byteslice( offset, 4 ).unpack1( "N" )
        type = data.byteslice( offset + 4, 4 )
        body = data.byteslice( offset + 8, length )
        animation[ :frames ], animation[ :plays ] = body.unpack( "NN" ) if type == "acTL"
        animation[ :delays ] << body.byteslice( 20, 4 ).unpack( "nn" ) if type == "fcTL"
        offset += 12 + length
      end
      animation
    end
end

#	shiny_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
