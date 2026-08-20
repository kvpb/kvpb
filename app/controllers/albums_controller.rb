class AlbumsController < ApplicationController
  include Paginatable

  before_action :set_album, only: %i[show edit update destroy]
  before_action :require_superuser, except: %i[index show]
  before_action :require_visible_album, only: :show
  before_action :redirect_if_section_empty, only: :index

  def index
    scope = superuser? ? Album.all.order( taken_until: :desc ) : Album.published
    @albums = paginate( scope )
  end

  def show
  end

  def new
    @album = Album.new
  end

  def create
    @album = Album.new( album_params )
    if @album.save
      @album.refresh_captured_period!
      redirect_to album_path( @album ), notice: "Album created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @album.update( album_params.except( :photos ) )
      @album.photos.attach( album_params[ :photos ] ) if album_params[ :photos ].present?
      @album.refresh_captured_period!
      redirect_to album_path( @album ), notice: "Album updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @album.destroy
    redirect_to see_path, notice: "Album deleted."
  end

  private
    def set_album
      @album = Album.find_by!( identifier: params[ :identifier ] )
    end

    def require_visible_album
      raise ActiveRecord::RecordNotFound if !@album.published? && !superuser?
    end

    def redirect_if_section_empty
      redirect_to root_path if helpers.section_empty?( :gallery ) && !superuser?
    end

    def album_params
      params.require( :album ).permit( :title, :location, :description, :identifier, :published_at, :cover_photo, photos: [] )
    end
end

#	albums_controller.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
