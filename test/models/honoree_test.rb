#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its
#	documentation for any purpose and without fee is hereby granted, provided that
#	the above copyright notice appear in all copies and that both that copyright
#	notice and this permission notice appear in supporting documentation, and that
#	the name of Karl Vincent Pierre Bertin not be used in advertising or publicity
#	pertaining to distribution of the software without specific, written prior
#	permission. Karl Vincent Pierre Bertin makes no representations about the
#	suitability of this software for any purpose.  It is provided "as is" without
#	express or implied warranty.

require "test_helper"

class HonoreeTest < ActiveSupport::TestCase
  test "assigns an identifier from the name when blank" do
    honoree = Honoree.create!( name: "Jane Doe", body: "Body" )
    assert_equal "jane-doe", honoree.identifier
  end

  test "disambiguates identifiers that would otherwise collide" do
    Honoree.create!( name: "Jane Doe", body: "Body" )
    other = Honoree.create!( name: "Jane Doe", body: "Body" )
    assert_equal "jane-doe-2", other.identifier
  end

  test "to_param returns the identifier" do
    assert_equal honorees( :published_human ).identifier, honorees( :published_human ).to_param
  end

  test "published scope excludes drafts" do
    assert_includes Honoree.published, honorees( :published_human )
    assert_not_includes Honoree.published, honorees( :draft_animal )
  end

  test "published? reflects published_at" do
    assert honorees( :published_human ).published?
    assert_not honorees( :draft_animal ).published?
  end

  test "kind distinguishes humans from animals" do
    assert honorees( :published_human ).human?
    assert honorees( :draft_animal ).animal?
  end

  test "a draft can be saved without a body" do
    honoree = Honoree.new( name: "Bare draft" )
    assert honoree.valid?
  end

  test "publishing requires a body" do
    honoree = Honoree.new( name: "Scheduled", published_at: 1.day.from_now )
    assert_not honoree.valid?
    assert_includes honoree.errors.attribute_names, :body
  end

  test "a future published_at schedules rather than publishes" do
    honoree = Honoree.create!( name: "Scheduled ahead", body: "Body", published_at: 1.day.from_now )
    assert_not honoree.published?
    assert_not_includes Honoree.published, honoree
  end
end

#	honoree_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
