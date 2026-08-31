class PhotosController < ApplicationController
  before_action :set_album
  before_action :set_photo, only: %i[edit update destroy]
  before_action :require_superuser

  def edit
  end

  def update
    @photo.apply_manual_fields!( photo_params )
    @album.refresh_captured_period!
    redirect_to album_path( @album ), notice: "Photo updated."
  end

  def destroy
    @photo.destroy
    @album.refresh_captured_period!
    redirect_to album_path( @album ), notice: "Photo deleted."
  end

  private
    def set_album
      @album = Album.find_by!( identifier: params[ :album_identifier ] )
    end

    def set_photo
      @photo = @album.photos.find( params[ :id ] )
    end

    def photo_params
      params.require( :photo ).permit( :taken_at, :author, :place, :camera, :lens )
    end
end

#	photos_controller.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
