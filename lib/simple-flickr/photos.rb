module Flickr
  # A collection of Photos. 
  class Photos
    include Enumerable

    def offset
      (current_page-1) * per_page
    end

    def current_page
      @attributes['page'].to_i
    end

    def per_page
      (@attributes['perpage'] || @attributes['per_page']).to_i
    end

    def total_entries
      @attributes['total'].to_i
    end

    def total_pages
      (total_entries.to_f / per_page).ceil
    end

    def next_page
      total_pages > current_page ? current_page+1 : nil
    end

    def previous_page
      current_page > 1 ? current_page-1 : nil
    end
    
    # Create a new Flickr::Photos collection using the provided Hpricot::Elem object, which should
    # contain an appropriate Photo response in XML from Flickr. 
    def initialize( result_xml, client )
      @photos = result_xml.search( 'photo' ).collect { |xml| Flickr::Photo.new( xml, client ) }
      @attributes = result_xml.attributes
    end
    
    # Iterate through all the Flickr::Photo objects.
    def each
      @photos.each { |photo| yield photo }
    end
    
    # Is this collection of photos empty?
    def empty?
      to_a.empty?
    end
    
    # How big is this collection?
    def size
      to_a.size
    end
    alias_method :length, :size
    
    # Allow Photos to be accessed as an Array
    def [](n)
      to_a[n]
    end
  end
end