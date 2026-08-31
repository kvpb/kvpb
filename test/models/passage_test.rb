require "test_helper"

class PassageTest < ActiveSupport::TestCase
  test "a heading alone is enough — that's the dated chapter opening a stretch of an album" do
    passage = album.passages.build( position: 1, heading: "6 February 2025, Thursday" )
    assert passage.valid?
  end

  test "a body alone is enough — that's a paragraph of the story between two photos" do
    passage = album.passages.build( position: 1, body: "We rolled out Friday morning." )
    assert passage.valid?
  end

  test "carrying neither is nothing at all" do
    passage = album.passages.build( position: 1 )
    assert_not passage.valid?
  end

  private
    def album
      @album ||= Album.create!( title: "Test Album" )
    end
end

#	passage_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
