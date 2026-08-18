require "test_helper"

class SkillTest < ActiveSupport::TestCase
  test "requires a name and a category" do
    skill = Skill.new

    assert_not skill.valid?
    assert_includes skill.errors.attribute_names, :name
    assert_includes skill.errors.attribute_names, :category
  end

  test "ordered sorts by position then by creation" do
    second = Skill.create!( category: :aptitudes_skills, name: "Second", position: 1 )
    first = Skill.create!( category: :aptitudes_skills, name: "First", position: 0 )

    assert_equal [ first, second ], Skill.ordered.where( id: [ first.id, second.id ] ).to_a
  end

  test "category_label reads the human label for the current category" do
    skill = Skill.new( category: :languages_programming_languages )

    assert_equal "languages & programming languages", skill.category_label
  end
end

#	skill_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
