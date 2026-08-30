class PassagesController < ApplicationController
  before_action :set_album
  before_action :set_passage, only: %i[edit update destroy]
  before_action :require_superuser

  def new
    # one past the last photo, so a passage written without a position in mind closes the album
    # rather than silently opening it
    @passage = @album.passages.build( position: @album.photos.maximum( :position ).to_i + 1 )
  end

  def create
    @passage = @album.passages.build( passage_params )
    if @passage.save
      redirect_to album_path( @album ), notice: "Passage added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @passage.update( passage_params )
      redirect_to album_path( @album ), notice: "Passage updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @passage.destroy
    redirect_to album_path( @album ), notice: "Passage deleted."
  end

  private
    def set_album
      @album = Album.find_by!( identifier: params[ :album_identifier ] )
    end

    def set_passage
      @passage = @album.passages.find( params[ :id ] )
    end

    def passage_params
      params.require( :passage ).permit( :position, :heading, :body )
    end
end

#	passages_controller.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
