class PhotoDwellsController < ApplicationController
  before_action :require_superuser, only: :index

  rate_limit to: 30, within: 1.minute, only: :create, with: -> { head :too_many_requests }

  # Public and anonymous by design — no visitor identity is ever read or stored here, only a single
  # number folded into the one running total Photo#record_dwell! keeps for this photo
  def create
    photo = Photo.find( params[ :id ] )
    photo.record_dwell!( params[ :seconds ] )
    head :no_content
  end

  def index
    @photos = Photo.includes( :album ).order( dwell_seconds: :desc ).limit( 50 )
    @max_dwell_seconds = @photos.first&.dwell_seconds.to_f
  end
end

#	photo_dwells_controller.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
