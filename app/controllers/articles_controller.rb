class ArticlesController < ApplicationController
  include Autosavable
  include Paginatable

  before_action :set_article, only: %i[show edit update destroy]
  before_action :require_superuser, except: %i[index show]
  before_action :require_visible_article, only: :show
  before_action :redirect_if_section_empty, only: :index

  def index
    scope = superuser? ? Article.all.order( created_at: :desc ) : Article.published
    @articles = paginate( scope )
  end

  def show
    @comments = @article.comments.visible.order( :created_at )
    @pending_comments = superuser? ? @article.comments.pending.order( :created_at ) : Comment.none
    @comment = Comment.new
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new( article_params )
    @article.save

    respond_to do |format|
      format.html do
        if @article.persisted? && @article.errors.empty?
          redirect_to article_path( @article ), notice: "Article created."
        else
          render :new, status: :unprocessable_entity
        end
      end
      format.json do
        if @article.persisted?
          render_autosave( @article, edit_path: edit_article_path( @article ), update_path: article_path( @article, format: :json ) )
        else
          render_autosave( @article, edit_path: nil, update_path: nil )
        end
      end
    end
  end

  def edit
  end

  def update
    success = @article.update( article_params )

    respond_to do |format|
      format.html do
        if success
          redirect_to article_path( @article ), notice: "Article updated."
        else
          render :edit, status: :unprocessable_entity
        end
      end
      format.json { render_autosave( @article, edit_path: edit_article_path( @article ), update_path: article_path( @article, format: :json ) ) }
    end
  end

  def destroy
    @article.destroy
    redirect_to read_path, notice: "Article deleted."
  end

  private
    def set_article
      @article = Article.find_by!( identifier: params[ :identifier ] )
    end

    def require_visible_article
      raise ActiveRecord::RecordNotFound if !@article.published? && !superuser?
    end

    def redirect_if_section_empty
      redirect_to root_path if helpers.section_empty?( :journal ) && !superuser?
    end

    def article_params
      params.require( :article ).permit( :kicker, :headline, :subheadline, :lede, :body, :identifier, :published_at, :comments_locked, :cover_image )
    end
end

#	articles_controller.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
