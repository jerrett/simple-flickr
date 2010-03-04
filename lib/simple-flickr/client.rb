module Flickr
  # This can be used to make any raw request to Flickr, 
  # using Flickr::Client#request.
  # 
  # You will be greeted with an Hpricot document in return, 
  # which you will then have to parse yourself. Lucky for you, 
  # Flickr provides pretty clean responses and very nice documentation
  # (at http://www.flickr.com/services/api/), so it should be pretty
  # easy to deal with. 
  #
  # Use this if the rest of this library doesn't wrap the calls you
  # need, or if you just want to do it all your way instead.
  class Client
    REST_ENDPOINT = "http://api.flickr.com/services/rest"
   
    # Create a new Flickr::Client object.
    #
    # === Parameters
    # api_key<String>:: The API Key provided to you by flickr.
    #
    # Please see http://www.flickr.com/services/api/
    # for more information.
    def initialize( api_key )
      @api_key = api_key
      @cached_requests = {}
    end

    # This is just to make it nicer to look at. Without this, the @cached_requests pile up and make a mess.
    def inspect # :nodoc:
      "<Flickr::Client api_key=\"#{@api_key}\">"
    end
    
    # Locate a person using their username or email address.
    #
    # === Parameters
    # :query<String>:: The flickr username or email address of the person you want to find.
    #
    # === Returns
    # Flickr::Person:: Proxy object representing a Flickr person.
    def person( query )
      Person.find( query, self )
    end

    # Find a single photo using the Flickr photo ID
    #
    # === Parameters
    # :photo_id<String>:: The flickr photo id (should be a ~10-digit integer)
    def photo( photo_id )
      Photo.find( photo_id, self )
    end
    
    # Find a single photoset using the Flickr photoset ID
    #
    # === Parameters
    # :photoset_id<String>:: The flickr photoset id (should be a ~10-digit integer)
    def photoset( photoset_id )
      PhotoSet.find( photoset_id, self )
    end
    
    # Make a request to flickr. This will cache (per Flickr::Client instance) requests to avoid uneccesary traffic.
    # This will raise a Flickr::RequestError if something goes wrong.
    # 
    # === Parameters
    # :method<String>:: The method to call. This is any method from the Flickr API:  http://www.flickr.com/services/api/ (but 
    # without the leading 'flickr.' in front of the method call.
    # :arguments<Hash>:: An (optional) hash of key/value arguments. This is whatever arguments the method you are calling expects.
    #
    # === Returns
    # Hpricot::Elem:: An Hpricot Elem object, representing the XML response.
    #
    #   flickr = Flickr::Client.new( 'myapikey' )
    #   flickr.request( 'favorites.getPublicList', :user_id => '66273938@N00', :per_page => 5 )
    def request( method, arguments = {} )
      url = REST_ENDPOINT + "?" + arguments.merge( 
        :api_key => @api_key, 
        :method => "flickr.#{method}" 
      ).collect { | key, value | "#{key}=#{URI.encode(value.to_s)}" }.sort.join( '&' )
      
      return @cached_requests[ url ] if @cached_requests.has_key? url
      
      begin 
        response = Hpricot.XML( open(url).read ).at('rsp')
      rescue Errno::ETIMEDOUT, OpenURI::HTTPError, Errno::ECONNRESET, SocketError, Errno::ECONNREFUSED => e
        raise RequestError.new(0, e)
      end
      raise RequestError.new(response.at('err')['code'], response.at('err')['msg']) unless response['stat'] == 'ok'
      
      @cached_requests[ url ] = response
    end
  end
end
