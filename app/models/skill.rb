class Skill < ApplicationRecord
  enum :category, {
    languages: 0,
    programming_languages: 1,
    frameworks: 2,
    software_development_software: 3,
    operating_systems: 4,
    licenses: 5,
    certifications: 6,
    degrees: 7,
    aptitudes_skills: 8,
    activities_interests: 9
  }

  validates :name, presence: true
  validates :category, presence: true

  scope :ordered, -> { order( :position, :created_at ) }

  # aptitudes_skills, activities_interests, and certifications are left out here on purpose: their records aren't
  # going anywhere, they're just not shown on the about-me page for now (certifications specifically because the
  # one record in it, from 42, was never actually earned — Karl dropped out before certifying)
  DISPLAYED_CATEGORIES = %w[
    languages programming_languages frameworks software_development_software
    operating_systems licenses degrees
  ].freeze

  CATEGORY_LABELS = {
    "languages" => "languages",
    "programming_languages" => "programming languages",
    "frameworks" => "frameworks",
    "software_development_software" => "software development software",
    "operating_systems" => "operating systems",
    "licenses" => "licenses",
    "certifications" => "certifications",
    "degrees" => "degrees",
    "aptitudes_skills" => "aptitudes & skills",
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
