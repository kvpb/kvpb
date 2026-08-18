class MilestonesController < ApplicationController
  before_action :set_milestone, only: %i[edit update destroy]
  before_action :require_superuser

  def new
    @milestone = Milestone.new
  end

  def create
    @milestone = Milestone.new( milestone_params )
    if @milestone.save
      redirect_to gettoknowandcontact_path, notice: "Milestone created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @milestone.update( milestone_params )
      redirect_to gettoknowandcontact_path, notice: "Milestone updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @milestone.destroy
    redirect_to gettoknowandcontact_path, notice: "Milestone deleted."
  end

  private
    def set_milestone
      @milestone = Milestone.find( params[ :id ] )
    end

    def milestone_params
      params.require( :milestone ).permit( :kind, :title, :organization, :location, :starts_on, :ends_on, :date_label, :description )
    end
end

#	milestones_controller.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
