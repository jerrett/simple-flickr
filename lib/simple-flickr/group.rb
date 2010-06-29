module Flickr
  
  # Represents a Flickr Group
  #
  # You can find the Flickr::Group by the NSID
  class Group
    include Proxy
    
    def initialize( xml, client ) # :nodoc: 
      super( xml, client )

      @attributes['id'] = xml['nsid'] || xml['id']
      @attributes['name'] ||= xml.search('name').text
      @attributes['description'] ||= xml.search('description').text
      @attributes['members'] = xml.search('members').text.to_i 
    end

    def self.find_by_id( nsid, client )
      return nil unless nsid.is_a? String
      xml = client.request( 'groups.getInfo', :group_id => nsid )

      new( xml.at('group'), client )
    end

    def photos( options = {} )
      options.merge!( :group_id => id )
      Photo.api_query( 'photos.search', @client, options )
    end
  end
end
