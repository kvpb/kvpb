# Two small additions to Active Storage, so that a camera's RAW file is treated like any other image it can make a
# variant of — see RawDeveloper for what a RAW is and how it is developed:
#
#   - Blob#variable? also answers yes for a RAW, known by its extension, since the content type it was uploaded as
#     is anything from image/tiff to octet-stream and cannot be relied on to say so
#   - the transformer that turns an image into a variant develops a RAW into a TIFF first, since ImageMagick cannot
#     read one itself, and goes on from there exactly as it does with a HEIC or a JPEG
module DevelopRawFirst
  private
    def process( file, format: )
      return super unless RawDeveloper.raw?( file.path )
      developed = RawDeveloper.develop( file.path )
      File.open( developed ) { |tiff| super( tiff, format: format ) }
    ensure
      FileUtils.rm_f( developed ) if developed
    end
end

module RawIsVariable
  def variable?
    super || RawDeveloper.raw?( filename.to_s )
  end
end

Rails.application.config.to_prepare do
  ActiveStorage::Transformers::ImageProcessingTransformer.prepend( DevelopRawFirst )
  ActiveStorage::Blob.prepend( RawIsVariable )
end

#	active_storage_raw.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
