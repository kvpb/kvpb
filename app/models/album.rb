class Album < ApplicationRecord
  has_many :photos, -> { order( :position ) }, dependent: :destroy
  has_one_attached :cover_photo

  before_validation :assign_identifier, if: -> { identifier.blank? && title.present? }

  validates :title, presence: true
  validates :identifier, presence: true, uniqueness: true

  scope :published, -> { where.not( published_at: nil ).where( published_at: ..Time.current ).order( taken_until: :desc ) }
  scope :draft, -> { where( published_at: nil ) }

  def to_param
    identifier
  end

  def published?
    published_at.present? && published_at <= Time.current
  end

  def cover
    return cover_photo if cover_photo.attached?
    photos.first&.image
  end

  # The album's own date isn't typed in — it's the span the photos themselves already carry, oldest
  # shot to most recent, so it stays honest to when the pictures were actually taken rather than
  # whenever they happened to get uploaded here. Each Photo's own taken_at is already resolved
  # (EXIF-read or manually overridden, Photo#refresh_from_exif! doesn't distinguish the two here) by
  # the time this runs, so this only ever aggregates already-computed dates, never re-reads EXIF
  # itself
  def refresh_captured_period!
    dates = photos.where.not( taken_at: nil ).pluck( :taken_at ).map( &:to_date )
    update!( taken_from: dates.min, taken_until: dates.max )
  end

  # The actual first and last dates, not a month collapsed down to hide them — same %B %-d, %Y
  # Print#exif's own original_date already displays elsewhere, so a date reads the same precision
  # everywhere on the site rather than the gallery alone rounding off to a month
  def captured_period_label
    return nil if taken_from.blank? || taken_until.blank?
    return taken_from.strftime( "%B %-d, %Y" ) if taken_from == taken_until
    "#{ taken_from.strftime( '%B %-d, %Y' ) } – #{ taken_until.strftime( '%B %-d, %Y' ) }"
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
