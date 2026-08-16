class Article < ApplicationRecord
  has_many :comments, dependent: :destroy
  has_one_attached :cover_image

  before_validation :assign_identifier, if: -> { identifier.blank? && headline.present? }

  validates :headline, presence: true
  validates :body, presence: true
  validates :identifier, presence: true, uniqueness: true

  scope :published, -> { where.not(published_at: nil).where(published_at: ..Time.current).order(published_at: :desc) }
  scope :draft, -> { where(published_at: nil) }

  def to_param
    identifier
  end

  def published?
    published_at.present? && published_at <= Time.current
  end

  private
    def assign_identifier
      base = headline.parameterize
      candidate = base
      suffix = 1
      while Article.where(identifier: candidate).where.not(id: id).exists?
        suffix += 1
        candidate = "#{base}-#{suffix}"
      end
      self.identifier = candidate
    end
end
