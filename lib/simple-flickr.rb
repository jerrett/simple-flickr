$:.unshift File.dirname(__FILE__)

# A good starting point is Flickr::Client. Quick and simple example usage:
#   
#   client = Flickr::Client.new( 'apikey' )
#   person = client.person( 'jerrett taylor' ) 
#   => #<Flickr::Person:0x11e5e14 ...>>
#   person.photosets.first.title
#   => "Macro"
#   person.photosets.first.photos
#   => [#<Flickr::Photo:0x116ab10 ...>]
#  
# There is some basic caching, so the above example while making two calls 
# to person.photosets, would only contact flickr once. 
#
# All Proxy classes include Flickr::Proxy which grants them Flickr::Proxy#api_query. This 
# allows you to retreive a collection  directly, for example if you want to get a list
# of photosets and you know the internal flickr user id (or 'nsid'), you 
# can do the following:
#   
#   client = Flickr::Client.new( 'yourapikey' )
#   PhotoSet.api_query( 'photosets.getPhotos', client, :photoset_id => 1234 )
#  
# Similarly, you could get a list of all of a people photos or favorites:
#   
#   client = Flickr::Client.new( 'yourapikey' )
#   Photo.api_query( 'favorites.getPublicList', client, :user_id => 'flickruserid' )
#   Photo.api_query( 'people.getPublicPhotos', client, :user_id => 'flickruserid' )
#  
# The benifit of this is that it will only do a single request, since you don't 
# need to lookup the ID's if you have them already.
module Flickr
  class RequestError < StandardError
    attr_accessor :status, :message
    def initialize( status, message )
      @status, @message = status.to_i, message
    end
    
    def to_s
      "#{message} (#{status})"
    end
  end
end

# Dependencies
require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'uri'

# Classes
require 'simple-flickr/proxy'
require 'simple-flickr/client'
require 'simple-flickr/person'
require 'simple-flickr/photos'
require 'simple-flickr/photo'
require 'simple-flickr/photo_set'
