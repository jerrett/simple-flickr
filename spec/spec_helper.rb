require File.dirname(__FILE__) + '/../lib/simple-flickr'
require 'ruby-debug'

# Let's make sure we don't contact flickr during specs.
# Overide open (open-uri) to just return flickr-xmli

class MockFlickrResponse
  def initialize(xml); @xml = xml; end
  def read; @xml; end
end

VALID_FLICKR_RESPONSE = MockFlickrResponse.new( '<?xml version="1.0" encoding="utf-8" ?><rsp stat="ok"></rsp>' )
INVALID_FLICKR_RESPONSE = MockFlickrResponse.new(  '<?xml version="1.0" encoding="utf-8" ?><rsp stat="fail"><err code="101" msg="Something went wrong" /></rsp>' )

class Flickr::Base
  def open( url )
    VALID_FLICKR_RESPONSE
  end
end

