module Flickr
  # Represents a Flickr Photo.
  class Photo
    include Proxy
    include Comparable
    
    # http://www.flickr.com/services/api/misc.urls.html
    PHOTO_SIZES = { 'square' => '_s', 'thumbnail' => '_t', 'small' => '_m', 'medium' => '', 'large' => '_b' }

    # Initialize the photo with an extra hack to ensure that various attributes are
    # present, no matter whether flicker provides them as attributes or as seperate
    # nodes (or by several different names, occasionally)
    #
    # === Parameters
    # See Flickr::Proxy#initialize
    def initialize( xml, client )
      super( xml, client )
      @attributes['title'] ||= xml.search('title').text
      @attributes['description'] = xml.search('description').text
      @attributes['uploaded_at'] = Time.at((@attributes.delete('dateuploaded') or @attributes.delete('dateupload')).to_i).utc
      @attributes['owner'] ||= xml.at('owner').attributes['nsid'] if xml.at('owner')
      @attributes['taken_at'] = begin
        Time.parse("#{@attributes.delete('datetaken')} UTC") if @attributes.include?('datetaken')
      rescue ArgumentError
        nil
      end
    end

    # Get the person associated with this photo
    #
    # === Returns
    # Flickr::Person: The associated person object
    def person
      Person.find_by_id( owner, @client )
    end

    # Comparison with another Flickr::PHoto.
    #
    # === Parameters
    # :other<Flickr::Photo>: The other photo to compare to.
    #
    # === Returns 
    # Integer: -1, 0, 1 if the id of this Photo is less than, equal to, or greater than the +other+ Photo.
    def <=>( other )
      return 0 if self.id == other.id
      self.id < other.id ? -1 : 1
    end
    
    # Return the url to an image for the specified size. This does not currently support 'original'. 
    #
    # === Parameters
    # :size<String>:: The desired size of the image. Can be +square+, +thumbnail+, +small+, +medium+, or +large+.
    #
    # === Returns
    # String:: The url to the image.
    def url( size = 'medium' )
      "http://farm#{farm}.static.flickr.com/#{server}/#{id}_#{secret}#{PHOTO_SIZES[size]}.jpg"
    end
    
    # Find Photos using a Flickr API method, a Flickr::Client and a hash of options. 
    #
    # This works the same as Flickr::Proxy#api_query, only it returns a Flickr::Photos object instead of an Array.
    def self.api_query( api_method, client, options )
      Flickr::Photos.new( client.request(api_method, options).at('photos|photoset'), client ) # Photosets, unlike every other photos result, returns in a <photosets> node instead of <photos>.
    end

    # Find a single photo using the Flickr photo ID and a Flickr::Client
    #
    # === Parameters
    # :photo_id<String>:: The flickr photo id (should be a ~10-digit integer)
    # :client<Flickr::Client>:: The flickr client object to use
    def self.find( photo_id, client )
      Photo.new( client.request('photos.getInfo', :photo_id => photo_id).at('photo'), client )
    end
  end
end
