module Flickr
  # Flickr Proxy
  # 
  # This contains shared functionality for Flickr Proxy classes.
  # 
  # Any class that includes this should call super on initialize to pass 
  # in the XML and Flickr::Client instance, if they overide initialize.
  # 
  # All attributes from the Hpricto::Elem passed in to initialize will be grabbed
  # and mapped to method calls, for example: 
  # 
  #   xml => #<Hpricot::Doc {emptyelem <foo id="3" foo="bar">}>
  #   
  #   test = Myclass.new( xml, client )
  #   test.id   => "3"
  #   test.foo  => "bar" 
  module Proxy
    attr_accessor :attributes
    
    # Create a new proxy class. This needs an Hpricot::Elem 
    # of the XML returned from Flickr, from Flickr::Client#request. 
    #
    # Typically you don't want to call this directly, and should be using
    # the +find+ method of the class instead.
    # 
    # === Parameters
    # :xml<Hpricot::Elem>:: XML from Flickr, in Hpricot form. 
    # :client<Flickr::Client>:: A Flickr::Client to use for communication with flickr.
    def initialize( xml, client )
      @attributes = xml.raw_attributes
      @client = client
    end
    
    # Return the id, instead of the object_id
    def id # :nodoc:
      @attributes[ 'id' ]
    end
    
    # This maps method calls to attributes.
    def method_missing( method, *args ) # :nodoc:
      return @attributes[method.to_s] if @attributes[method.to_s]
      super
    end

    # Class methods.
    module ClassMethods
      # Find objects using a Flickr API method, a Flickr::Client and a hash of options. 
      #
      # this is mostly intended for internal use, but can also be used to directly call
      # specific api methods.
      #
      # === Parameters 
      # :client<Flickr::Client>:: Instance of a Flickr::Client to use to make the request.
      # :api_method<String>:: The Flickr API method to use. Must return nodes matching the class this is called on. (example, 'photosets' for Flickr::PhotoSet)
      # :options<Hash>:: Options to be passed along to the Flickr API Method.
      #
      # === Returns
      # Array[Flickr::Photo]:: An Array of Flickr::Photo objects. 
      def api_query(api_method, client, options = {} ) 
        client.request( api_method, options ).search( self.to_s.gsub('Flickr::','').downcase ).collect { |xml| new( xml, client ) }
      end
    end
    
    def self.included(klass) # :nodoc:
      klass.extend(ClassMethods)
    end
  end
end




