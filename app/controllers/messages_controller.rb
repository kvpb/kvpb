class MessagesController < ApplicationController
  before_action :require_superuser
  before_action :set_message, only: %i[mark_read mark_unread forward]

  def index
    @messages = Message.chronological
  end

  def mark_read
    @message.update!( read: true )
    redirect_to messages_path
  end

  def mark_unread
    @message.update!( read: false )
    redirect_to messages_path
  end

  def forward
    ContactMailer.forward( @message ).deliver_now
    redirect_to messages_path, notice: "Message forwarded."
  end

  private
    def set_message
      @message = Message.find( params[ :id ] )
    end
end

#	messages_controller.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
