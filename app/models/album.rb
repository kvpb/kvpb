class Album < ApplicationRecord
  has_many_attached :photos
  has_one_attached :cover_photo

  before_validation :assign_identifier, if: -> { identifier.blank? && title.present? }

  validates :title, presence: true
  validates :identifier, presence: true, uniqueness: true

  scope :published, -> { where.not( published_at: nil ).where( published_at: ..Time.current ).order( taken_on: :desc ) }
  scope :draft, -> { where( published_at: nil ) }

  def to_param
    identifier
  end

  def published?
    published_at.present? && published_at <= Time.current
  end

  def cover
    cover_photo.attached? ? cover_photo : photos.first
  end

  private
    def assign_identifier
      base = title.parameterize
      candidate = base
      suffix = 1
      while Album.where( identifier: candidate ).where.not( id: id ).exists?
        suffix += 1
        candidate = "#{base}-#{suffix}"
      end
      self.identifier = candidate
    end
end

#	album.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
