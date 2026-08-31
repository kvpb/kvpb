require "net/http"
require "csv"

# The error statuses errors_controller.rb answers to (see config/routes.rb) are read from here, never typed
# out by hand: RefreshHttpStatusRegistryJob refreshes it daily (config/recurring.yml) from the IANA HTTP
# Status Code Registry itself (https://www.iana.org/assignments/http-status-codes/), the one place both MDN
# and RFC 9110 point back to for the complete, current list — RFC 9110 only defines the core of it directly,
# naming this registry as the authority for the rest. A code with no real name there — a whole range simply
# "Unassigned", or "(Unused)" the way 306 and 418 both are, MDN's own page for the second notwithstanding —
# is never one of these
class HttpStatusRegistry
  CSV_URL = "https://www.iana.org/assignments/http-status-codes/http-status-codes-1.csv"
  CACHE_KEY = "http_status_registry:error_codes"

  # Read fresh on every request a status route answers to (config/routes.rb's own constraint) — cheap, this
  # being Rails.cache (Solid Cache, its own database table, never a network call), and it means a code the
  # registry only just added shows up here the next time refresh! runs, no redeploy needed. Only refresh!
  # ever writes to this key
  def self.error_codes
    Rails.cache.fetch( CACHE_KEY ) { FALLBACK }
  end

  # Read once a day, never once a request: IANA's own registry changes on the order of years, not days, and
  # this is a plain network call, the one this class refuses to ever make from inside a request/response
  # cycle. Left entirely alone — cache included — if the fetch or the parse fails for any reason: a stale but
  # correct list is always better than none at all
  def self.refresh!
    codes = parse( fetch )
    Rails.cache.write( CACHE_KEY, codes ) if codes.present?
  rescue StandardError => e
    Rails.logger.error( "HttpStatusRegistry.refresh! failed: #{ e.message }" )
  end

  # The registry's own CSV export
  def self.fetch
    uri = URI( CSV_URL )
    request = Net::HTTP::Get.new( uri )
    request[ "User-Agent" ] = "kvpb.fr HTTP status registry check"
    response = Net::HTTP.start( uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 5 ) { |http| http.request( request ) }
    raise "HTTP #{ response.code }" unless response.is_a?( Net::HTTPSuccess )
    response.body
  end

  # A row is a real, named error status — kept only if its own Value parses as one plain code (a range like
  # "419-420" never does, so Integer() rejects it, exactly as wanted), at 400 or over, and its Description
  # isn't blank, isn't literally "Unassigned", and doesn't start with "(" the way every "(Unused)" one does
  def self.parse( csv_text )
    CSV.parse( csv_text, headers: true ).each_with_object( {} ) do |row, codes|
      code = Integer( row[ "Value" ], exception: false )
      next if code.nil? || code < 400
      description = row[ "Description" ].to_s
      next if description.blank? || description == "Unassigned" || description.start_with?( "(" )
      codes[ code ] = description
    end
  end

  # What error_codes answers with before refresh! has ever run once — the registry read by hand, in full,
  # the same day this was written
  FALLBACK = {
    400 => "Bad Request", 401 => "Unauthorized", 402 => "Payment Required", 403 => "Forbidden",
    404 => "Not Found", 405 => "Method Not Allowed", 406 => "Not Acceptable",
    407 => "Proxy Authentication Required", 408 => "Request Timeout", 409 => "Conflict", 410 => "Gone",
    411 => "Length Required", 412 => "Precondition Failed", 413 => "Content Too Large",
    414 => "URI Too Long", 415 => "Unsupported Media Type", 416 => "Range Not Satisfiable",
    417 => "Expectation Failed", 421 => "Misdirected Request", 422 => "Unprocessable Content",
    423 => "Locked", 424 => "Failed Dependency", 425 => "Too Early", 426 => "Upgrade Required",
    428 => "Precondition Required", 429 => "Too Many Requests", 431 => "Request Header Fields Too Large",
    451 => "Unavailable For Legal Reasons", 500 => "Internal Server Error", 501 => "Not Implemented",
    502 => "Bad Gateway", 503 => "Service Unavailable", 504 => "Gateway Timeout",
    505 => "HTTP Version Not Supported", 506 => "Variant Also Negotiates", 507 => "Insufficient Storage",
    508 => "Loop Detected", 510 => "Not Extended (OBSOLETED)", 511 => "Network Authentication Required"
  }.freeze
end

#	http_status_registry.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
