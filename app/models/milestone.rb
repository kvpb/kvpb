class Milestone < ApplicationRecord
  enum :kind, { education: 0, work: 1, birth: 2 }

  validates :title, presence: true
  validates :organization, presence: true, unless: :birth?
  validates :starts_on, presence: true

  scope :chronological, -> { order( starts_on: :desc ) }

  # real milestones, most recent first, with an unpersisted ("It's a secret to everybody.") filler Milestone
  # spliced in wherever two successive periods neither overlap nor continue from one month to the next — a real
  # gap the timeline doesn't otherwise account for. Comparing every milestone only to its immediate neighbor by
  # start date isn't enough: a milestone can run for years underneath several shorter ones nested inside it (the
  # SHS degree here spans 2015–2018 with an unrelated internship inside that range), so the gap check tracks the
  # furthest "covered through" point seen so far, not just the previous milestone's own end, the standard
  # interval-merging approach. Two birth-kind milestones never get a filler between them regardless of the gap —
  # birth is a single moment, not a stretch of unaccounted-for lived time, so there's nothing to call "a secret"
  # between two of them (concretely: nothing appears between "probable former life" and "birth" itself). Never
  # persisted — .new, never .save — so nothing here ever reaches the DB
  def self.chronological_with_gaps
    ascending = chronological.reverse
    return ascending.reverse if ascending.size < 2

    entries = [ ascending.first ]
    covered_through = effective_end_on( ascending.first )
    previous = ascending.first

    ascending.drop( 1 ).each do |milestone|
      gap_between_two_births = previous.birth? && milestone.birth?
      if !gap_between_two_births && month_index( milestone.starts_on ) - month_index( covered_through ) > 1
        entries << gap_filler( covered_through, milestone.starts_on )
      end
      entries << milestone
      covered_through = [ covered_through, effective_end_on( milestone ) ].max
      previous = milestone
    end

    entries.reverse
  end

  # date_label_ends_on exists for exactly one situation: starts_on holds a real, precise date, but date_label
  # hides it behind something vaguer ("nineties") for anyone reading the page — including, deliberately, a gap
  # filler counting from it, which would otherwise leak the hidden precision right back out via its own "from
  # <precise date>" wording. Set, it says where the *labeled* range actually ends for gap-computation purposes,
  # regardless of what starts_on itself says
  def self.effective_end_on( milestone )
    return milestone.date_label_ends_on if milestone.date_label_ends_on.present?
    return milestone.starts_on if milestone.birth?
    milestone.ends_on || Date.current
  end
  private_class_method :effective_end_on

  def self.month_index( date )
    date.year * 12 + date.month
  end
  private_class_method :month_index

  def self.gap_filler( covered_through, next_starts_on )
    new(
      kind: :work,
      title: "It's a secret to everybody.",
      starts_on: covered_through.beginning_of_month >> 1,
      ends_on: ( next_starts_on.beginning_of_month << 1 ).end_of_month
    )
  end
  private_class_method :gap_filler

  def ongoing?
    ends_on.nil?
  end

  def date_range_label
    return date_label if date_label.present?

    starts_label = starts_on.strftime( "%B %Y" )
    return starts_label if !ongoing? && ends_on.strftime( "%B %Y" ) == starts_label

    # a non-breaking space between "to" and what follows it, so a wrap lands before "to" rather than stranding it alone at the end of a line
    "from #{starts_label} to\u00A0#{ongoing? ? "now" : ends_on.strftime( "%B %Y" )}"
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
