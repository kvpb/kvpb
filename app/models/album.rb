require "exifr/jpeg"

class Album < ApplicationRecord
  has_many_attached :photos
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
    cover_photo.attached? ? cover_photo : photos.first
  end

  # The album's own date isn't typed in — it's the span the photos themselves already carry in
  # their EXIF, oldest shot to most recent, so it stays honest to when the pictures were actually
  # taken rather than whenever they happened to get uploaded here
  def refresh_captured_period!
    dates = photos.filter_map { |photo| captured_date_for( photo ) }
    update!( taken_from: dates.min, taken_until: dates.max )
  end

  def captured_period_label
    return nil if taken_from.blank? || taken_until.blank?
    return taken_from.strftime( "%B %Y" ) if taken_from.year == taken_until.year && taken_from.month == taken_until.month
    return "#{ taken_from.strftime( '%B' ) } – #{ taken_until.strftime( '%B %Y' ) }" if taken_from.year == taken_until.year
    "#{ taken_from.strftime( '%B %Y' ) } – #{ taken_until.strftime( '%B %Y' ) }"
  end

  private
    # A screenshot, a scan, a PNG export — anything without a real camera's own EXIF block behind
    # it — has nothing to contribute here, so it's silently left out of the span rather than
    # treated as an error
    def captured_date_for( photo )
      photo.blob.open do |file|
        EXIFR::JPEG.new( file.path ).date_time_original&.to_date
      end
    rescue EXIFR::MalformedJPEG
      nil
    end

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
