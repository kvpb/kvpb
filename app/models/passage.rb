class Passage < ApplicationRecord
  belongs_to :album

  validates :position, presence: true
  validate :heading_or_body_present

  private
    # A passage carrying neither is nothing at all. Either alone is a real thing, though: a heading
    # by itself is the dated chapter opening a stretch of an album, a body by itself a paragraph of
    # the story running between two photos, and the two together a section opened by its own title
    def heading_or_body_present
      return if heading.present? || body.present?
      errors.add( :base, "A passage needs a heading, a body, or both." )
    end
end

#	passage.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
