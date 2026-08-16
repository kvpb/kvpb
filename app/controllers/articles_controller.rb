class ArticlesController < ApplicationController
  before_action :set_article, only: %i[show edit update destroy]
  before_action :require_superuser, except: %i[index show]
  before_action :require_visible_article, only: :show

  def index
    @articles = superuser? ? Article.all.order(created_at: :desc) : Article.published
  end

  def show
    @comments = @article.comments.visible.order(:created_at)
    @pending_comments = superuser? ? @article.comments.pending.order(:created_at) : Comment.none
    @comment = Comment.new
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to article_path(@article), notice: "Article created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @article.update(article_params)
      redirect_to article_path(@article), notice: "Article updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article.destroy
    redirect_to read_path, notice: "Article deleted."
  end

  private
    def set_article
      @article = Article.find_by!(identifier: params[:identifier])
    end

    def require_visible_article
      raise ActiveRecord::RecordNotFound if !@article.published? && !superuser?
    end

    def article_params
      params.require(:article).permit(:kicker, :headline, :subheadline, :lede, :body, :identifier, :published_at, :comments_locked, :cover_image)
    end
end
