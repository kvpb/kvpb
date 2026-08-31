require "net/http"
require "json"

class PhotoGeocodeJob < ApplicationJob
  queue_as :default

  # Nominatim (OpenStreetMap) — free, no API key, in exchange for a real, identifying User-Agent and
  # a one-request-per-second ceiling this project doesn't enforce across concurrent jobs, since a
  # personal gallery is never uploading photos fast enough for that to matter in practice. Runs as
  # its own job, off the request/response cycle, specifically because of that ceiling rather than
  # blocking a photo upload on a network round trip
  def perform( photo_id )
    photo = Photo.find_by( id: photo_id )
    return if photo.nil? || photo.place_overridden? || photo.latitude.blank? || photo.longitude.blank?

    place = reverse_geocode( photo.latitude, photo.longitude )
    return if place.blank?

    # Karl may have set the place by hand while this job was in flight — refuse to clobber that
    photo.update!( place: place ) unless photo.reload.place_overridden?
  end

  private
    def reverse_geocode( latitude, longitude )
      uri = URI( "https://nominatim.openstreetmap.org/reverse" )
      uri.query = URI.encode_www_form( lat: latitude, lon: longitude, format: "jsonv2" )
      request = Net::HTTP::Get.new( uri )
      request[ "User-Agent" ] = "kvpb.fr photo geocoding"

      response = Net::HTTP.start( uri.host, uri.port, use_ssl: true ) { |http| http.request( request ) }
      return nil unless response.is_a?( Net::HTTPSuccess )

      address = JSON.parse( response.body )[ "address" ] || {}
      locality = address[ "city" ] || address[ "town" ] || address[ "village" ] || address[ "municipality" ]
      [ locality, address[ "country" ] ].compact.join( ", " ).presence
    rescue StandardError
      nil
    end
end

#	photo_geocode_job.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
