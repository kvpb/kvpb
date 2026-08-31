class PrintsController < ApplicationController
  before_action :set_print, only: :show
  before_action :require_visible_print, only: :show

  def show
  end

  private
    def set_print
      @print = Print.find_by!( identifier: params[ :identifier ] )
    end

    def require_visible_print
      raise ActiveRecord::RecordNotFound if !@print.published? && !superuser?
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
