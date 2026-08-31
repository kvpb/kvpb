class RegistrationsController < ApplicationController
  rate_limit to: 5, within: 1.hour, only: :create, with: -> { redirect_to new_registration_path, alert: "Try again later." }

  def new
    if Setting.current.registration_enabled?
      @user = User.new
    else
      render :disabled
    end
  end

  def create
    unless Setting.current.registration_enabled?
      render :disabled
      return
    end

    @user = User.new( registration_params )

    if @user.save
      start_new_session_for @user
      redirect_to after_authentication_url, notice: "Account created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def registration_params
      params.require( :user ).permit( :username, :email_address, :password, :password_confirmation )
    end
end

#	registrations_controller.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
