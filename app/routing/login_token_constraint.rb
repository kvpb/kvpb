#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its
#	documentation for any purpose and without fee is hereby granted, provided that
#	the above copyright notice appear in all copies and that both that copyright
#	notice and this permission notice appear in supporting documentation, and that
#	the name of Karl Vincent Pierre Bertin not be used in advertising or publicity
#	pertaining to distribution of the software without specific, written prior
#	permission. Karl Vincent Pierre Bertin makes no representations about the
#	suitability of this software for any purpose.  It is provided "as is" without
#	express or implied warranty.

class LoginTokenConstraint
  def self.matches?( request )
    presented_token = request.path.split( "/", 3 )[ 1 ].to_s
    current_token = Setting.current.login_token.to_s

    current_token.present? && ActiveSupport::SecurityUtils.secure_compare( presented_token, current_token )
  end
end

#	login_token_constraint.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
