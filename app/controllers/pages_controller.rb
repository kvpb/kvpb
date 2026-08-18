class PagesController < ApplicationController
  before_action :redirect_if_section_empty, only: %i[listen watch]

  def listen
  end

  def watch
  end

  def gettoknowandcontact
    @milestones = Milestone.chronological
    @message = Message.new
    @profile_photo = Setting.current.profile_photo
    @skills_by_category = Skill.ordered.group_by( &:category )
  end

  def search
  end

  private
    def redirect_if_section_empty
      section = action_name == "listen" ? :music : :films
      redirect_to root_path if helpers.section_empty?( section ) && !superuser?
    end
end

#	pages_controller.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
