class Skill < ApplicationRecord
  enum :category, { aptitudes_skills: 0, degrees_certifications_licenses: 1, languages_programming_languages: 2, activities_interests: 3 }

  validates :name, presence: true
  validates :category, presence: true

  scope :ordered, -> { order( :position, :created_at ) }

  CATEGORY_LABELS = {
    "aptitudes_skills" => "aptitudes & skills",
    "degrees_certifications_licenses" => "degrees, certifications & licenses",
    "languages_programming_languages" => "languages & programming languages",
    "activities_interests" => "activities & interests"
  }.freeze

  def category_label
    CATEGORY_LABELS.fetch( category )
  end
end

#	skill.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
