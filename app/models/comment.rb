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

class Comment < ApplicationRecord
  belongs_to :article
  belongs_to :user, optional: true

  enum :status, { pending: 0, approved: 1 }

  before_validation :approve_when_authored_by_user

  validates :body, presence: true
  validates :author_name, :author_email, presence: true, if: -> { user_id.blank? }
  validates :author_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  scope :visible, -> { approved }

  def author_display_name
    user&.username || author_name
  end

  private
    def approve_when_authored_by_user
      self.status = :approved if user_id.present?
    end
end

#	comment.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
