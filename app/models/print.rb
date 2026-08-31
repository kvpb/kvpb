class Print < ApplicationRecord
  include WebImage

  has_one_attached :image
  has_secure_token :identifier

  scope :published, -> { where.not( published_at: nil ).where( published_at: ..Time.current ).order( published_at: :desc ) }
  scope :draft, -> { where( published_at: nil ) }

  def to_param
    identifier
  end

  def published?
    published_at.present? && published_at <= Time.current
  end

  # The photograph's own facts, read fresh off it every time rather than kept in a column — a Print, unlike a
  # Photo, has nowhere of its own to hold a manual override, so there is nothing to keep in sync. Empty rather
  # than raising for one with nothing readable in it (a screenshot, a scan), same as exif_data itself
  def exif
    data = exif_data
    return {} unless data
    {
      original_date: data.date_time_original,
      camera: [ data.make, data.model ].compact.join( " " ).presence,
      lens: data.lens_model,
      gps: gps_label( data.gps )
    }.compact
  end

  private
    def gps_label( gps )
      return nil unless gps&.latitude && gps&.longitude
      "#{gps.latitude.round( 5 )}, #{gps.longitude.round( 5 )}"
    end
end

#	print.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
