module Flickr
  
  # Represents a Flickr Person.
  #
  # You can find a Flickr::Person by email or by username, 
  # using Flickr::Person#find. 
  class Person
    include Proxy
    
    def initialize( xml, client ) # :nodoc:
      super( xml, client )

      @attributes.merge!( 
        'id' => xml[ 'nsid' ],
        'profileurl' => xml.search('profileurl').text,
        'photosurl' => xml.search('photosurl').text,
        'location' => xml.search('location').text,
        'realname' => xml.search('realname').text,
        'username' => xml.search('username').text
      )
    end
    
    # Return the most recent photos from a persons photostream. 
    # 
    # === Arguments
    # :options<Hash>:: This is a hash of options that will be passed to flickr. For more details
    # on what you can pass, please check out http://www.flickr.com/services/api/flickr.people.getPublicPhotos.html
    #
    # === Returns
    # [Flickr::Photo]:: An array of Flickr::Photo objects.
    def photos( options = {} )
      Photo.api_query( 'people.getPublicPhotos', @client, options.merge(:user_id => id)  )
    end
    
    def groups
      xml = @client.request( 'people.getPublicGroups', :user_id => id )
      return xml.search('group').collect { |g| Flickr::Group.new(g, @client) }
    end

    # Return the persons photosets.
    # 
    # === Returns
    # [Flickr::PhotoSet]:: An array of Flickr::PhotoSet objects.
    def photosets
      PhotoSet.api_query( 'photosets.getList', @client, :user_id => id )
    end
    
    # Return the most recent photos from a persons favorites. 
    # 
    # === Arguments
    # :options<Hash>:: This is a hash of options that will be passed to flickr. For more details
    # on what you can pass, please check out http://www.flickr.com/services/api/flickr.favorites.getPublicList.html
    #
    # === Returns
    # [Flickr::Photo]:: An array of Flickr::Photo objects.
    def favorites( options )
      Photo.api_query( 'favorites.getPublicList', @client, options.merge(:user_id => id) )
    end
    
    # Find a person on Flickr using their flickr username or email address.
    #
    # === Parameters
    # :query<String>:: The Flickr username or email address of the person.
    # :client<Flickr::Client>:: A Flickr::Client to use for communication with flickr.
    #
    # === Returns
    # Flickr::Person:: An instance of Flickr::Person representing the person, or nil
    # if no people can be found.
    def self.find( query, client )
      return nil unless query.is_a? String
      
      begin
        if query.include? '@'
          xml = client.request( 'people.findByEmail', :find_email => query )       
        else
          xml = client.request( 'people.findByUsername', :username => query )
        end
      rescue => e
        return nil if e.respond_to? :status and e.status == 1
        raise e
      end
      
      find_by_id( xml.at('user')['nsid'], client )
    end

    # Find a user using their flickr user id. Use this if you already know the NSID
    # of a user, instead of #find.
    #
    # === Parameters
    # :user_id<String>:: The Flickr User id (NSID).
    # :client<Flickr::Client>:: A Flickr::Client to use for communication with flickr.
    #
    # === Returns
    # Flickr::Person:: An instance of Flickr::Person representing the person, or nil
    # if no people can be found.
    def self.find_by_id( user_id, client )
      begin
        userxml = client.request( 'people.getInfo', :user_id => user_id )
      rescue => e
        return nil if e.respond_to? :status and e.status == 1
        raise e
      end
      
      new( userxml.at('person'), client )
    end
    
  end
end
