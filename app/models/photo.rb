require "exifr/jpeg"

class Photo < ApplicationRecord
  belongs_to :album
  has_one_attached :image

  validates :position, presence: true

  # Reads every EXIF-derivable field off the image's own blob and writes whichever fields aren't
  # currently overridden — same open-blob/EXIFR::JPEG pattern Print#exif already established. A
  # photo with no readable EXIF (a screenshot, a scan) just keeps those fields blank rather than
  # raising; EXIFR::MalformedJPEG is the one error EXIFR itself raises for that case
  def refresh_from_exif!
    data = exif_data
    attrs = {}
    attrs[ :taken_at ] = data&.date_time_original unless taken_at_overridden?
    attrs[ :author ] = data&.artist unless author_overridden?
    attrs[ :camera ] = camera_from( data ) unless camera_overridden?
    attrs[ :lens ] = data&.lens_model unless lens_overridden?
    unless place_overridden?
      attrs[ :latitude ] = data&.gps&.latitude
      attrs[ :longitude ] = data&.gps&.longitude
    end
    update!( attrs )

    PhotoGeocodeJob.perform_later( id ) if !place_overridden? && latitude.present? && longitude.present?
  end

  # A field submitted blank means "go back to automatic" — its own override flag clears here, and
  # the refresh_from_exif! call right after fills it back in from the blob's own EXIF, still present
  # regardless of what's been overridden in the past. A field submitted with a value is the override
  # itself, stored as-is
  def apply_manual_fields!( fields )
    attrs = {}
    %i[ taken_at author place camera lens ].each do |field|
      value = fields[ field ]
      overridden = value.present?
      attrs[ field ] = value if overridden
      attrs[ :"#{ field }_overridden" ] = overridden
    end
    update!( attrs )
    refresh_from_exif!
  end

  # Never trusts the value handed in — a visitor's own browser reports its own dwell time, so it's
  # clamped to a plausible single-visit range regardless of what's claimed, before an atomic
  # increment (not a read-modify-write) folds it into the one running total this photo keeps. No
  # per-visitor breakdown exists anywhere; this column is the only thing dwell time ever becomes
  def record_dwell!( seconds )
    increment!( :dwell_seconds, seconds.to_f.clamp( 0, 300 ) )
  end

  private
    def exif_data
      return nil unless image.attached?
      image.blob.open do |file|
        EXIFR::JPEG.new( file.path )
      end
    rescue EXIFR::MalformedJPEG
      nil
    end

    def camera_from( data )
      [ data&.make, data&.model ].compact.join( " " ).presence
    end
end

#	photo.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
