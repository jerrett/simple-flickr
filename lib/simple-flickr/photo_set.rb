module Flickr
  
  # Represents a Flickr Photo Set.
  class PhotoSet
    include Proxy
    
    def initialize( xml, client ) # :nodoc:
      super( xml, client )
      @attributes[ 'title' ] = xml.at('title').inner_text 
      @attributes[ 'description' ] = xml.at('description').inner_text 
    end

    # Return the most recent photos for this photoset. 
    # 
    # === Arguments
    # :options<Hash>:: This is a hash of options that will be passed to flickr. For more details
    # on what you can pass, please check out http://www.flickr.com/services/api/flickr.photosets.getPhotos.html
    #
    # === Returns
    # [Flickr::Photo]:: An array of Flickr::Photo objects.
    def photos( options = {} )
      Photo.api_query( 'photosets.getPhotos', @client, options.merge(:photoset_id => id) )
    end
    
    # Get the person associated with this photoset
    #
    # === Returns
    # Flickr::Person: The associated person object
    def person
      Person.find_by_id( owner, @client )
    end
    
    # Find a single photo using the Flickr photo ID and a Flickr::Client
    #
    # === Parameters
    # :photoset_id<String>:: The flickr photoset id (should be a ~10-digit integer)
    # :client<Flickr::Client>:: The flickr client object to use
    def self.find( photoset_id, client )
      PhotoSet.new( client.request('photosets.getInfo', :photoset_id => photoset_id).at('photoset'), client )
    end
  end
end
