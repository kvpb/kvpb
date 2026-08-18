class ContactsController < ApplicationController
  rate_limit to: 5, within: 1.minute, only: :create, with: -> { redirect_to gettoknowandcontact_path, alert: "Try again later." }

  def create
    if honeypot_tripped?
      redirect_to gettoknowandcontact_path, notice: "Message sent."
      return
    end

    @contact = Contact.new( contact_params )
    if @contact.valid?
      ContactMailer.new_message( @contact ).deliver_now
      redirect_to gettoknowandcontact_path, notice: "Message sent."
    else
      redirect_to gettoknowandcontact_path, alert: @contact.errors.full_messages.to_sentence
    end
  end

  private
    def honeypot_tripped?
      params.dig( :contact, :website ).present?
    end

    def contact_params
      params.require( :contact ).permit( :name, :phone_number, :email_address, :body )
    end
end

#	contacts_controller.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
