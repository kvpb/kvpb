class CommentsController < ApplicationController
  before_action :set_article
  before_action :require_visible_article, only: :create
  before_action :set_comment, only: %i[approve reject]
  before_action :require_superuser, only: %i[approve reject]

  rate_limit to: 5, within: 1.minute, only: :create, with: -> { redirect_to article_path(params[:article_identifier]), alert: "Try again later." }

  def create
    if honeypot_tripped?
      redirect_to article_path(@article), notice: "Comment submitted."
      return
    end

    if @article.comments_locked?
      redirect_to article_path(@article), alert: "Comments are locked for this article."
      return
    end

    @comment = @article.comments.build(comment_params)
    @comment.user = Current.user if authenticated?

    if @comment.save
      redirect_to article_path(@article), notice: @comment.approved? ? "Comment posted." : "Comment submitted for review."
    else
      redirect_to article_path(@article), alert: @comment.errors.full_messages.to_sentence
    end
  end

  def approve
    @comment.update!(status: :approved)
    redirect_to article_path(@article), notice: "Comment approved."
  end

  def reject
    CommentMailer.rejected(@comment).deliver_now
    @comment.destroy
    redirect_to article_path(@article), notice: "Comment rejected."
  end

  private
    def set_article
      @article = Article.find_by!(identifier: params[:article_identifier])
    end

    def require_visible_article
      raise ActiveRecord::RecordNotFound if !@article.published? && !superuser?
    end

    def set_comment
      @comment = @article.comments.find(params[:id])
    end

    def honeypot_tripped?
      params.dig(:comment, :website).present?
    end

    def comment_params
      params.require(:comment).permit(:author_name, :author_email, :body)
    end
end
