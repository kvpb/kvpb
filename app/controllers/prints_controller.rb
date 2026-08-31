class PrintsController < ApplicationController
  before_action :set_print, only: %i[show edit update destroy]
  before_action :require_admin, except: :show
  before_action :require_visible_print, only: :show

  def show
  end

  def new
    @print = Print.new
  end

  def create
    @print = Print.new( print_params )
    if @print.save
      redirect_to print_path( @print ), notice: "Print created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @print.update( print_params )
      redirect_to print_path( @print ), notice: "Print updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @print.destroy
    redirect_to see_path, notice: "Print deleted."
  end

  private
    def set_print
      @print = Print.find_by!( identifier: params[ :identifier ] )
    end

    def require_visible_print
      raise ActiveRecord::RecordNotFound if !@print.published? && !admin?
    end

    def print_params
      params.require( :print ).permit( :title, :identifier, :published_at, :image )
    end
end

#	prints_controller.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
