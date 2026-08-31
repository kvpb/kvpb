class PhotoDwellEventsController < ApplicationController
  before_action :require_superuser
  before_action :set_event, only: :destroy

  # Newest first — the real-time log Karl can eyeball for a burst of implausibly identical events
  # (a bot's own signature), as opposed to the ordinary, varied trickle a real audience leaves
  def index
    @events = PhotoDwellEvent.includes( photo: :album ).order( created_at: :desc ).limit( 200 )
  end

  # The inverse of the increment record_dwell! made when this event was logged — never a full
  # recompute, just this one event's own seconds handed back out of the photo's running total
  def destroy
    photo = @event.photo
    ActiveRecord::Base.transaction do
      photo.decrement!( :dwell_seconds, @event.seconds )
      @event.destroy!
    end
    redirect_to photo_dwell_events_path, notice: "Event removed."
  end

  private
    def set_event
      @event = PhotoDwellEvent.find( params[ :id ] )
    end
end

#	photo_dwell_events_controller.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
