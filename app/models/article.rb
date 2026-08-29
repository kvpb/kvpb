class Article < ApplicationRecord
  has_many :comments, dependent: :destroy
  has_one_attached :cover_image

  before_validation :assign_identifier, if: -> { identifier.blank? && headline.present? }

  validates :headline, presence: true
  validates :body, presence: true, if: :published_at?
  validates :identifier, presence: true, uniqueness: true

  scope :published, -> { where.not( published_at: nil ).where( published_at: ..Time.current ).order( published_at: :desc ) }
  scope :draft, -> { where( published_at: nil ) }

  # What an editor actually does with a front page: a ranked article is placed by hand and comes
  # first, everything unranked falls in behind it newest-first, which is where an article sits until
  # it's worth moving. `front_page_rank IS NULL` sorts false (0) before true (1), putting the ranked
  # ones ahead — spelled that way rather than as NULLS LAST, which only some SQLite builds accept.
  # COALESCE lets a draft, which has no published_at, fall back on when it was written, so the
  # superuser's own view of the page stays in a sane order instead of collapsing every draft together
  scope :front_page_ordered, -> {
    order( Arel.sql( "front_page_rank IS NULL, front_page_rank ASC, COALESCE( published_at, created_at ) DESC" ) )
  }

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
      while Article.where( identifier: candidate ).where.not( id: id ).exists?
        suffix += 1
        candidate = "#{base}-#{suffix}"
      end
      self.identifier = candidate
    end
end

#	article.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
