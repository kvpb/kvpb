# What the find overlay looks for: the webpages of the site, one result each. The sections that are on show, under the
# words a visitor would use for them, and the pages inside them, an article, an album, a print, found by what they
# contain, an album by its photos and its written passages as well as by its own title; and the about me page, found by
# the skills and milestones it lists. Each result carries just enough to be drawn as a card and to link to the page.
# Matching is a plain substring, case-insensitive on ASCII, so a query needs no syntax. What isn't published isn't
# found, and the Hall of Fame, which is linked from nowhere, is never looked in
class Search
  MINIMUM_LENGTH = 2
  LIMIT_PER_KIND = 6

  Result = Struct.new( :kind, :title, :detail, :path, :image, keyword_init: true )

  # what a visitor might type to mean each section, besides its own name
  SECTION_WORDS = {
    read: [ "read", "journal", "article", "articles", "news", "newspaper", "front page", "blog", "writing", "text" ],
    see: [ "see", "gallery", "photo", "photos", "photograph", "photographs", "photography", "album", "albums", "picture", "pictures", "image", "images", "print", "prints" ],
    about: [ "about", "about me", "get to know", "contact", "contact me", "message", "timeline", "skills", "cv", "resume", "who" ]
  }.freeze

  attr_reader :query

  def initialize( query )
    @query = query.to_s.strip
  end

  def results
    return [] if query.length < MINIMUM_LENGTH

    sections + about + articles + albums + prints
  end

  private
    def routes
      Rails.application.routes.url_helpers
    end

    def pattern
      @pattern ||= "%#{ ActiveRecord::Base.sanitize_sql_like( query ) }%"
    end

    def matching( scope, *columns )
      condition = columns.map { |column| "#{ scope.table_name }.#{ column } LIKE :pattern ESCAPE '\\'" }.join( " OR " )
      scope.where( condition, pattern: pattern ).limit( LIMIT_PER_KIND )
    end

    def excerpt( text )
      text.to_s.squish.truncate( 110, separator: " " )
    end

    def image_path( attachment )
      routes.rails_blob_path( attachment, only_path: true ) if attachment&.attached?
    end

    def count( number, noun )
      "#{ number } #{ noun.pluralize( number ) }"
    end

    def word_matches?( key )
      SECTION_WORDS.fetch( key ).any? { |word| word.include?( query.downcase ) }
    end

    # the sections that are on show, previewed: what is in them, and the latest picture from them when there is one
    def sections
      found = []

      if word_matches?( :read ) && Article.published.exists?
        latest = Article.published.first
        found << Result.new( kind: "section", title: "read", detail: "#{ count( Article.published.count, "article" ) } · latest: #{ excerpt( latest.headline ) }", path: routes.read_path, image: image_path( latest.cover_image ) )
      end

      if word_matches?( :see ) && Album.published.exists?
        latest = Album.published.first
        summary = [ count( Album.published.count, "album" ), count( Photo.where( album: Album.published ).count, "photo" ), count( Print.published.count, "print" ) ].join( " · " )
        found << Result.new( kind: "section", title: "see", detail: summary, path: routes.see_path, image: image_path( latest.cover ) )
      end

      found
    end

    # one page for everything on it: named as a section, or found by a skill or a milestone it lists, in which case
    # the card says which
    def about
      matched = matching( Skill.where( category: Skill::DISPLAYED_CATEGORIES ).ordered, :name ).pluck( :name ) +
        matching( Milestone.chronological, :title, :organization, :location, :description, :date_label ).pluck( :title )
      return [] unless word_matches?( :about ) || matched.any?

      detail = word_matches?( :about ) || matched.empty? ? "who I am, told as a timeline, and a way to reach me" : excerpt( matched.first( 2 ).join( " · " ) )
      [ Result.new( kind: "section", title: "get to know & contact", detail: detail, path: routes.gettoknowandcontact_path ) ]
    end

    def articles
      matching( Article.published, :headline, :subheadline, :kicker, :lede, :body ).map do |article|
        Result.new( kind: "article", title: article.headline, detail: excerpt( article.subheadline.presence || article.lede ), path: routes.article_path( article ) )
      end
    end

    # an album is found by its own words, by the metadata of a photo in it, or by a passage written in it, and shown
    # once, saying which
    def albums
      found = {}
      matching( Album.published, :title, :description, :location ).each { |album| found[ album ] ||= excerpt( album.description.presence || album.location ) }
      matching( Photo.joins( :album ).merge( Album.published ).includes( :album ), :place, :camera, :lens, :author ).each do |photo|
        found[ photo.album ] ||= [ photo.place, photo.camera, photo.lens, photo.author ].compact_blank.join( " · " )
      end
      matching( Passage.joins( :album ).merge( Album.published ).includes( :album ), :heading, :body ).each do |passage|
        found[ passage.album ] ||= excerpt( [ passage.heading, passage.body ].find { |part| part.to_s.downcase.include?( query.downcase ) } )
      end

      found.first( LIMIT_PER_KIND ).map do |album, detail|
        Result.new( kind: "album", title: album.title.presence || album.identifier, detail: detail, path: routes.album_path( album ) )
      end
    end

    def prints
      matching( Print.published, :title ).map do |print|
        Result.new( kind: "print", title: print.title.presence || print.identifier, detail: nil, path: routes.print_path( print ) )
      end
    end
end

#	search.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
