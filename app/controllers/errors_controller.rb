# ActionController::Base directly, not ApplicationController: this is what an old browser is sent to once
# ApplicationController's own allow_browser turns it away, so inheriting that same check back would turn this
# page away too, in a loop. Nothing here needs a signed-in session either — every one of these is a page
# anybody, browser or session however broken, has to be able to see
class ErrorsController < ActionController::Base
  layout "error"

  # One action for every one of them: the five Rails itself ever raises on its own, arriving here by
  # PATH_INFO rewritten to "/#{status}" (config.exceptions_app), and any other three digits at all,
  # arriving here by someone typing kvpb.fr/503 (or any of the rest) directly — the easter egg
  def show
    @status = params[ :status ].to_i
    render "errors/show", status: @status
  end
end

#	errors_controller.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
