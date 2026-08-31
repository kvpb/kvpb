require "test_helper"

class HttpStatusRegistryTest < ActiveSupport::TestCase
  SAMPLE_CSV = <<~CSV
    Value,Description,Reference
    306,(Unused),"[RFC9110, Section 15.4.7]"
    309-399,Unassigned,
    400,Bad Request,"[RFC9110, Section 15.5.1]"
    418,(Unused),"[RFC9110, Section 15.5.19]"
    419-420,Unassigned,
    429,Too Many Requests,[RFC6585]
    510,Not Extended (OBSOLETED),[RFC2774][Status change of HTTP experiments to Historic]
  CSV

  # test.rb's own cache_store is :null_store — nothing it ever writes actually holds — so error_codes and
  # refresh! are swapped onto a real one for the length of each test here, and back after, same idea as
  # replacing below for a class method instead of Rails.cache itself
  setup do
    @original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
  end

  teardown do
    Rails.cache = @original_cache
  end

  test "parse keeps only real, named error statuses — no ranges, no Unassigned, no (Unused), nothing under 400" do
    codes = HttpStatusRegistry.parse( SAMPLE_CSV )

    assert_equal( { 400 => "Bad Request", 429 => "Too Many Requests", 510 => "Not Extended (OBSOLETED)" }, codes )
  end

  test "error_codes reads whatever was last written under its own cache key" do
    Rails.cache.write( HttpStatusRegistry::CACHE_KEY, { 999 => "Made Up" } )

    assert_equal( { 999 => "Made Up" }, HttpStatusRegistry.error_codes )
  end

  test "error_codes falls back to the hand-read snapshot when refresh! has never run" do
    assert_equal( HttpStatusRegistry::FALLBACK, HttpStatusRegistry.error_codes )
  end

  test "refresh! writes what fetch and parse gave it" do
    replacing( HttpStatusRegistry, :fetch, -> { SAMPLE_CSV } ) do
      HttpStatusRegistry.refresh!
    end

    assert_equal( { 400 => "Bad Request", 429 => "Too Many Requests", 510 => "Not Extended (OBSOLETED)" }, HttpStatusRegistry.error_codes )
  end

  test "refresh! leaves the cache exactly as it was if fetch itself fails" do
    Rails.cache.write( HttpStatusRegistry::CACHE_KEY, { 111 => "Kept" } )

    replacing( HttpStatusRegistry, :fetch, -> { raise "network is down" } ) do
      HttpStatusRegistry.refresh!
    end

    assert_equal( { 111 => "Kept" }, HttpStatusRegistry.error_codes )
  end

  private
    # minitest 6 no longer ships stub: a class method is swapped for the length of the block, then put back
    def replacing( object, name, with )
      original = object.method( name )
      object.define_singleton_method( name, &with )
      yield
    ensure
      object.define_singleton_method( name, original )
    end
end

#	http_status_registry_test.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
