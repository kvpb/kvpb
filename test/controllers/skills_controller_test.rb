require "test_helper"

class SkillsControllerTest < ActionDispatch::IntegrationTest
  test "new requires a signed-in superuser" do
    get new_skill_path
    assert_redirected_to new_session_path( token: login_token )

    sign_in_as( users( :two ) )
    get new_skill_path
    assert_redirected_to root_path
  end

  test "create requires a signed-in superuser" do
    assert_no_difference( "Skill.count" ) do
      post skills_path, params: { skill: { category: "aptitudes_skills", name: "Rigor" } }
    end
  end

  test "a superuser can create a skill" do
    sign_in_as( users( :one ) )

    assert_difference( "Skill.count", 1 ) do
      post skills_path, params: { skill: { category: "aptitudes_skills", name: "Rigor" } }
    end

    assert_redirected_to gettoknowandcontact_path
  end

  test "a superuser can update a skill" do
    sign_in_as( users( :one ) )
    skill = Skill.create!( category: :aptitudes_skills, name: "Rigor" )

    patch skill_path( skill ), params: { skill: { name: "Precision" } }

    assert_equal "Precision", skill.reload.name
  end

  test "a superuser can delete a skill" do
    sign_in_as( users( :one ) )
    skill = Skill.create!( category: :aptitudes_skills, name: "Rigor" )

    assert_difference( "Skill.count", -1 ) do
      delete skill_path( skill )
    end
  end
end

#	skills_controller_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
