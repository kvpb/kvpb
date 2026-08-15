class CommentMailer < ApplicationMailer
  def rejected(comment)
    @comment = comment
    @article = comment.article

    mail to: comment.author_email, subject: "Your comment on “#{@article.headline}” was not approved"
  end
end
