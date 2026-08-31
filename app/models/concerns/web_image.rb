require "exifr/jpeg"

# What a Photo and a Print share: an attached image that might not be one a browser can read at all — an
# iPhone's HEIC, or a camera's own RAW — and metadata that has to come from wherever it actually still is: a
# RAW carries none of its own over into what it's developed into, so exiftool reads that off the RAW itself;
# everything else is read by EXIFR, off the JPEG a browser is shown, which does carry the original's over
module WebImage
  extend ActiveSupport::Concern

  # What a browser is shown of this photograph. A JPEG, PNG, GIF or WebP goes out exactly as it is; anything
  # else Active Storage can convert — an iPhone's HEIC above all, which no browser can display — is shown as a
  # JPEG made from it by ImageMagick, stood upright by its own orientation, the first time anyone asks for it,
  # and kept from then on like any other file. The original is never touched: it stays in storage as it came,
  # with its own name and its own bytes, and is what the photograph is always read from
  def web_image
    return image if !image.attached? || image.blob.content_type.in?( ActiveStorage.web_image_content_types ) || !image.variable?
    image.variant( format: :jpeg, auto_orient: true, quality: 90 )
    # image.variant( format: :jpeg, auto_orient: true, saver: { quality: 90 } )
  end

  private
    # Reads whatever EXIF the attachment actually carries — a RAW's own, by exiftool, since developing it into
    # something a browser can show carries none of it over; a JPEG's, or the JPEG made of anything else, by
    # EXIFR, which reads only JPEG. Nil for a photograph with nothing readable in it (a screenshot, a scan)
    # rather than raising, as everywhere else
    def exif_data
      return nil unless image.attached?
      return image.blob.open { |file| RawDeveloper.exif( file.path ) } if RawDeveloper.raw?( image.filename.to_s )
      exif_blob.open do |file|
        EXIFR::JPEG.new( file.path )
      end
    rescue EXIFR::MalformedJPEG
      nil
    end

    # EXIFR only reads JPEG, so a photograph in any other format is read from the JPEG made of it for the
    # browsers, which carries the original's EXIF over; a JPEG is read as it is. A RAW is neither: the picture
    # developed from it carries nothing, so it is read from the RAW itself, by exiftool, just above
    def exif_blob
      derived = web_image
      derived.respond_to?( :processed ) ? derived.processed.image.blob : image.blob
    end
end

#	web_image.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
