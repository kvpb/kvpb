class HonoreesController < ApplicationController
  include Autosavable

  before_action :set_honoree, only: %i[show edit update destroy]
  before_action :require_superuser, except: %i[index show]
  before_action :require_visible_honoree, only: :show

  def index
    @honorees = superuser? ? Honoree.all.order( :name ) : Honoree.published
  end

  def show
  end

  def new
    @honoree = Honoree.new
  end

  def create
    @honoree = Honoree.new( honoree_params )
    @honoree.save

    respond_to do |format|
      format.html do
        if @honoree.persisted? && @honoree.errors.empty?
          redirect_to honoree_path( @honoree ), notice: "Honoree created."
        else
          render :new, status: :unprocessable_entity
        end
      end
      format.json do
        if @honoree.persisted?
          render_autosave( @honoree, edit_path: edit_honoree_path( @honoree ), update_path: honoree_path( @honoree, format: :json ) )
        else
          render_autosave( @honoree, edit_path: nil, update_path: nil )
        end
      end
    end
  end

  def edit
  end

  def update
    success = @honoree.update( honoree_params )

    respond_to do |format|
      format.html do
        if success
          redirect_to honoree_path( @honoree ), notice: "Honoree updated."
        else
          render :edit, status: :unprocessable_entity
        end
      end
      format.json { render_autosave( @honoree, edit_path: edit_honoree_path( @honoree ), update_path: honoree_path( @honoree, format: :json ) ) }
    end
  end

  def destroy
    @honoree.destroy
    redirect_to hall_of_fame_path, notice: "Honoree deleted."
  end

  private
    def set_honoree
      @honoree = Honoree.find_by!( identifier: params[ :identifier ] )
    end

    def require_visible_honoree
      raise ActiveRecord::RecordNotFound if !@honoree.published? && !superuser?
    end

    def honoree_params
      params.require( :honoree ).permit(
        :name, :kind, :birth_date, :death_date,
        :known_from, :known_until, :helped_from, :helped_until,
        :honor_inscription, :body, :identifier, :published_at, :hero_image
      )
    end
end

#	honorees_controller.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
