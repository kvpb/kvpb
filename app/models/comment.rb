class Comment < ApplicationRecord
  belongs_to :article
  belongs_to :user, optional: true

  enum :status, { pending: 0, approved: 1 }

  before_validation :approve_when_authored_by_user

  validates :body, presence: true
  validates :author_name, :author_email, presence: true, if: -> { user_id.blank? }
  validates :author_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  scope :visible, -> { approved }

  def author_display_name
    user&.username || author_name
  end

  private
    def approve_when_authored_by_user
      self.status = :approved if user_id.present?
    end
end
