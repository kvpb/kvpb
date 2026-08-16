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

class Honoree < ApplicationRecord
  has_one_attached :hero_image

  enum :kind, { human: 0, animal: 1 }

  before_validation :assign_identifier, if: -> { identifier.blank? && name.present? }

  validates :name, presence: true
  validates :body, presence: true, if: :published_at?
  validates :identifier, presence: true, uniqueness: true

  scope :published, -> { where.not( published_at: nil ).where( published_at: ..Time.current ).order( :name ) }
  scope :draft, -> { where( published_at: nil ) }

  def to_param
    identifier
  end

  def published?
    published_at.present? && published_at <= Time.current
  end

  private
    def assign_identifier
      base = name.parameterize
      candidate = base
      suffix = 1
      while Honoree.where( identifier: candidate ).where.not( id: id ).exists?
        suffix += 1
        candidate = "#{base}-#{suffix}"
      end
      self.identifier = candidate
    end
end

#	honoree.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
