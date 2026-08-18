module ApplicationHelper
  def smart_quotes( text )
    sanitize( RubyPants.new( text.to_s ).to_html, tags: [] )
  end

  def smart_format( text )
    simple_format( RubyPants.new( text.to_s ).to_html )
  end

  def section_empty?( section )
    case section
    when :journal then !Article.published.exists?
    when :gallery then !Album.published.exists?
    when :music, :films then true
    end
  end

  def current_section_suffix
    if controller_name == "articles"
      { label: "journal", empty: section_empty?( :journal ) }
    elsif controller_name == "albums"
      { label: "gallery", empty: section_empty?( :gallery ) }
    elsif controller_name == "pages" && action_name == "listen"
      { label: "music", empty: section_empty?( :music ) }
    elsif controller_name == "pages" && action_name == "watch"
      { label: "films", empty: section_empty?( :films ) }
    elsif %w[messages milestones skills].include?( controller_name )
      { label: "back end", empty: false }
    end
  end
end

#	application_helper.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
