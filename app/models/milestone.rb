class Milestone < ApplicationRecord
  enum :kind, { education: 0, work: 1, birth: 2 }

  validates :title, presence: true
  validates :organization, presence: true, unless: :birth?
  validates :starts_on, presence: true

  scope :chronological, -> { order( starts_on: :desc ) }

  def ongoing?
    ends_on.nil?
  end

  def date_range_label
    return date_label if date_label.present?

    starts_label = starts_on.strftime( "%B %Y" )
    return starts_label if !ongoing? && ends_on.strftime( "%B %Y" ) == starts_label

    "from #{starts_label} to #{ongoing? ? "now" : ends_on.strftime( "%B %Y" )}"
  end
end

#	milestone.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
