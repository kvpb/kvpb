require "open3"
require "json"
require "tempfile"

# A camera's RAW file is not something a browser can show, nor something the ImageMagick in the production image can read
# (its own RAW route hands the file to a program Debian no longer carries). So it is developed here first, by LibRaw's
# own dcraw_emu, into an ordinary 8-bit sRGB TIFF, using the white balance the camera measured and the rotation it
# recorded — and only then handed to ImageMagick, like any other TIFF, to be made into the JPEG a browser is shown.
# Nothing here ever touches the RAW file itself: it is read, and that is all
#
# A RAW is known by its extension, never by the content type the upload was given: most of them are TIFF inside, and
# come out of Marcel as image/tiff, or as one of a dozen image/x-raw-* names, or as nothing more than octet-stream
#
# The developed picture carries none of the RAW's metadata, so what a photograph is dated, taken with and taken at
# is read from the RAW itself, by exiftool, which reads every make's — EXIFR reads only JPEG, and a few TIFF
class RawDeveloper
  class Error < StandardError; end

  EXTENSIONS = %w[ .3fr .arw .cr2 .cr3 .crw .dng .erf .iiq .kdc .mrw .nef .nrw .orf .pef .raf .raw .rw2 .rwl .sr2 .srf .srw .x3f ].freeze
  Exif = Struct.new( :date_time_original, :artist, :make, :model, :lens_model, :gps )
  Position = Struct.new( :latitude, :longitude )

  def self.raw?( name )
    EXTENSIONS.include?( File.extname( name.to_s ).downcase )
  end

  # The developed TIFF, a file of its own beside the RAW, which is the caller's to delete
  def self.develop( raw_path )
    _out, err, status = Open3.capture3( "dcraw_emu", "-T", "-w", "-o", "1", "-Z", ".tiff", raw_path.to_s )
    developed = "#{ raw_path }.tiff"
    raise Error, "dcraw_emu could not develop #{ File.basename( raw_path.to_s ) }: #{ err.strip }" unless status.success? && File.size?( developed )
    developed
  rescue Errno::ENOENT
    raise Error, "dcraw_emu is not installed (libraw-bin)"
  end

  # What EXIFR gives for a JPEG — the date it was taken, its artist, make, model and lens, and where — read by exiftool
  # off any file it knows, or nothing at all if it can't, so that a photograph with nothing readable in it stays blank
  # rather than raising, as everywhere else
  def self.exif( path )
    out, _err, status = Open3.capture3( "exiftool", "-j", "-n", "-DateTimeOriginal", "-Artist", "-Make", "-Model", "-LensModel", "-GPSLatitude", "-GPSLongitude", path.to_s )
    return nil unless status.success?
    tags = JSON.parse( out ).first
    return nil if tags.blank?
    Exif.new( taken( tags[ "DateTimeOriginal" ] ), tags[ "Artist" ], tags[ "Make" ], tags[ "Model" ], tags[ "LensModel" ], position( tags ) )
  rescue Errno::ENOENT, JSON::ParserError
    nil
  end

  # "2018:07:27 17:57:33", in the time of the machine that reads it, exactly as EXIFR reads the same field of a JPEG
  def self.taken( text )
    year, month, day, hour, minute, second = text.to_s.scan( /\d+/ ).map( &:to_i )
    return nil if year.to_i.zero? || month.to_i.zero?
    Time.local( year, month, day, hour, minute, second )
  rescue ArgumentError
    nil
  end

  def self.position( tags )
    return nil unless tags[ "GPSLatitude" ].is_a?( Numeric ) && tags[ "GPSLongitude" ].is_a?( Numeric )
    Position.new( tags[ "GPSLatitude" ], tags[ "GPSLongitude" ] )
  end
end

#	raw_developer.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
