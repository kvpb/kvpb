module SessionTestHelper
  def login_token
    Setting.current.login_token
  end

  def sign_in_as( user )
    Current.session = user.sessions.create!

    ActionDispatch::TestRequest.create.cookie_jar.tap do |cookie_jar|
      cookie_jar.signed[ :session_id ] = Current.session.id
      cookies[ "session_id" ] = cookie_jar[ :session_id ]
    end
  end

  def sign_out
    Current.session&.destroy!
    cookies.delete( "session_id" )
  end
end

ActiveSupport.on_load( :action_dispatch_integration_test ) do
  include SessionTestHelper
end

#	session_test_helper.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
