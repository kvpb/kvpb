require "test_helper"

class MilestoneTest < ActiveSupport::TestCase
  test "requires a title, organization, and starts_on" do
    milestone = Milestone.new

    assert_not milestone.valid?
    assert_includes milestone.errors.attribute_names, :title
    assert_includes milestone.errors.attribute_names, :organization
    assert_includes milestone.errors.attribute_names, :starts_on
  end

  test "chronological orders by starts_on descending" do
    older = Milestone.create!( title: "Older", organization: "Org", starts_on: 2.years.ago )
    newer = Milestone.create!( title: "Newer", organization: "Org", starts_on: 1.year.ago )

    assert_equal [ newer, older ], Milestone.chronological.where( id: [ older.id, newer.id ] ).to_a
  end

  test "ongoing? reflects a blank ends_on" do
    ongoing = Milestone.new( ends_on: nil )
    finished = Milestone.new( ends_on: Date.current )

    assert ongoing.ongoing?
    assert_not finished.ongoing?
  end

  test "date_range_label collapses a single-month range to one date" do
    single_month = Milestone.new( starts_on: "2014-09-01", ends_on: "2014-09-30" )
    assert_equal "September 2014", single_month.date_range_label
  end

  test "date_range_label shows a range across two different months" do
    multi_month = Milestone.new( starts_on: "2014-01-01", ends_on: "2015-07-31" )
    assert_equal "January 2014 – July 2015", multi_month.date_range_label
  end

  test "date_range_label shows 'present' when ongoing" do
    ongoing = Milestone.new( starts_on: "2023-09-01", ends_on: nil )
    assert_equal "September 2023 – present", ongoing.date_range_label
  end

  test "kind distinguishes education from work from birth" do
    education = Milestone.new( kind: :education )
    work = Milestone.new( kind: :work )
    birth = Milestone.new( kind: :birth )

    assert education.education?
    assert work.work?
    assert birth.birth?
  end

  test "a birth milestone doesn't require an organization" do
    birth = Milestone.new( kind: :birth, title: "Birth", starts_on: Date.current )

    assert birth.valid?
  end

  test "date_range_label prefers an explicit date_label override" do
    imprecise = Milestone.new( starts_on: "1990-01-01", date_label: "1990s" )
    assert_equal "1990s", imprecise.date_range_label
  end
end

#	milestone_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
