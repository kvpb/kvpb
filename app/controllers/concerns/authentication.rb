module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :resume_session
    helper_method :authenticated?, :superuser?, :login_token
  end

  private
    def authenticated?
      Current.user.present?
    end

    def superuser?
      Current.user&.superuser? || false
    end

    def login_token
      Setting.current.login_token
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      Session.find_by( id: cookies.signed[ :session_id ] ) if cookies.signed[ :session_id ]
    end

    def request_authentication
      session[ :return_to_after_authenticating ] = request.url
      redirect_to new_session_path( token: login_token ), alert: "Sign in to continue."
    end

    def after_authentication_url
      session.delete( :return_to_after_authenticating ) || root_url
    end

    def require_superuser
      unless authenticated?
        request_authentication
        return
      end

      redirect_to root_path, alert: "You are not authorized to do that." unless superuser?
    end

    def start_new_session_for( user )
      user.sessions.create!( user_agent: request.user_agent, ip_address: request.remote_ip ).tap do |session|
        Current.session = session
        cookies.signed.permanent[ :session_id ] = { value: session.id, httponly: true, same_site: :lax }
      end
    end

    def terminate_session
      Current.session.destroy
      cookies.delete( :session_id )
    end
end

#	authentication.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
