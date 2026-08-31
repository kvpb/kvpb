module Paginatable
  extend ActiveSupport::Concern

  PER_PAGE = 10

  private
    def paginate( scope )
      @page = [ params[ :page ].to_i, 1 ].max
      @total_pages = ( scope.count / PER_PAGE.to_f ).ceil
      scope.offset( ( @page - 1 ) * PER_PAGE ).limit( PER_PAGE )
    end
end

#	paginatable.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
