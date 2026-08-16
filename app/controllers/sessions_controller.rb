class SessionsController < ApplicationController
  before_action :set_no_index_headers, only: :new

  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path( token: login_token ), alert: "Try again later." }

  def new
  end

  def create
    if user = User.authenticate_by( params.permit( :email_address, :password ) )
      start_new_session_for user
      redirect_to after_authentication_url, notice: "Signed in."
    else
      redirect_to new_session_path( token: login_token ), alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to root_path, status: :see_other, notice: "Signed out."
  end

  private
    def set_no_index_headers
      response.headers[ "X-Robots-Tag" ] = "noindex, nofollow"
      response.headers[ "Cache-Control" ] = "no-store"
    end
end

#	sessions_controller.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
