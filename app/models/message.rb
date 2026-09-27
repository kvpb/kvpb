class Message < MessagesRecord
  # nobody who reaches the form gets to fill the disk: every field has a ceiling, and only the latest KEPT messages stay —
  # except the ones I tag to keep, which no amount of new arrivals ever pushes out
  MAX_NAME = 100
  MAX_PHONE_NUMBER = 30
  MAX_EMAIL_ADDRESS = 254
  MAX_BODY = 5000
  KEPT = 100

  validates :name, presence: true, length: { maximum: MAX_NAME }
  validates :phone_number, presence: true, length: { maximum: MAX_PHONE_NUMBER }
  validates :email_address, presence: true, length: { maximum: MAX_EMAIL_ADDRESS }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :body, presence: true, length: { maximum: MAX_BODY }

  scope :chronological, -> { order( created_at: :desc ) }

  after_create_commit :forget_the_oldest

  private
    def forget_the_oldest
      loose = self.class.where( kept: false )
      loose.where.not( id: loose.order( created_at: :desc, id: :desc ).limit( KEPT ).select( :id ) ).delete_all
    end
end

#	message.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
