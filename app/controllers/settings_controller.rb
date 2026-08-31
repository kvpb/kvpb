class SettingsController < ApplicationController
  before_action :require_admin

  def edit
    @setting = Setting.current
  end

  def update
    Setting.current.update!( setting_params )
    redirect_to settings_path, notice: "Settings saved."
  end

  private
    def setting_params
      params.require( :setting ).permit( :twitter_visible, :github_visible )
    end
end

#	settings_controller.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
