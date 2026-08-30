class SkillsController < ApplicationController
  before_action :set_skill, only: %i[edit update destroy]
  before_action :require_superuser

  def new
    @skill = Skill.new
  end

  def create
    @skill = Skill.new( skill_params )
    if @skill.save
      redirect_to gettoknowandcontact_path, notice: "Skill created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @skill.update( skill_params )
      redirect_to gettoknowandcontact_path, notice: "Skill updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @skill.destroy
    redirect_to gettoknowandcontact_path, notice: "Skill deleted."
  end

  private
    def set_skill
      @skill = Skill.find( params[ :id ] )
    end

    def skill_params
      params.require( :skill ).permit( :category, :name, :position )
    end
end

#	skills_controller.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
