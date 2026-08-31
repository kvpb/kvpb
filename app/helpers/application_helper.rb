module ApplicationHelper
  def smart_quotes( text )
    sanitize( RubyPants.new( text.to_s ).to_html, tags: [] )
  end

  def smart_format( text )
    simple_format( RubyPants.new( text.to_s ).to_html )
  end

  def format_dwell( seconds )
    total = seconds.to_i
    "%dm %02ds" % [ total / 60, total % 60 ]
  end

  # The strip a newspaper runs under its flag. Every figure in it is derived rather than typed:
  # the volume counts the years the journal has been running, the number counts what it has actually
  # published — so the line keeps itself true without anyone maintaining it. No city, unlike the
  # Times' own "NEW YORK": that's a real fact about a real place, and inventing one here would be
  # inventing something about Karl
  def journal_dateline
    first = Article.published.minimum( :published_at )
    volume = first ? ( Date.current.year - first.year ) + 1 : 1
    [
      "Vol. #{ roman( volume ) }",
      "No. #{ Article.published.count }",
      l( Date.current, format: :long ),
      "Late Edition"
    ].join( " · " )
  end

  ROMAN_NUMERALS = { 1000 => "M", 900 => "CM", 500 => "D", 400 => "CD", 100 => "C", 90 => "XC",
                     50 => "L", 40 => "XL", 10 => "X", 9 => "IX", 5 => "V", 4 => "IV", 1 => "I" }.freeze

  def roman( number )
    remainder = number.to_i
    return "" if remainder < 1

    ROMAN_NUMERALS.each_with_object( +"" ) do |( value, numeral ), result|
      while remainder >= value
        result << numeral
        remainder -= value
      end
    end
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
      { label: "journal", label_ja: "ジャーナル", empty: section_empty?( :journal ) }
    elsif controller_name == "albums"
      { label: "gallery", label_ja: "ギャラリー", empty: section_empty?( :gallery ) }
    elsif controller_name == "pages" && action_name == "listen"
      { label: "music", empty: section_empty?( :music ) }
    elsif controller_name == "pages" && action_name == "watch"
      { label: "films", empty: section_empty?( :films ) }
    elsif %w[messages milestones skills photo_dwells photo_dwell_events].include?( controller_name )
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
