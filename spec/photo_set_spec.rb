require File.dirname(__FILE__) + '/spec_helper.rb'

describe Flickr::PhotoSet do
  before( :each ) do 
    @client = mock( 'Flickr::Client' )
    user_xml = Hpricot.parse( '<photos page="2" pages="89" perpage="10" total="881"><photoset id="5" primary="2483" secret="abcdef" server="8" photos="4" farm="1"><title>Test</title><description>foo</description></photoset></photosets>' )
    @photoset = Flickr::PhotoSet.new( user_xml.at('photoset'), @client )
  end

  it 'should include proxy' do 
    Flickr::PhotoSet.included_modules.include?( Flickr::Proxy ).should == true
  end
  
  it 'should grab the title and description from the xml' do
    @photoset.title.should == 'Test'
    @photoset.description.should == 'foo'
  end

  it 'should use the passed in client' do 
    @photoset.instance_variable_get( :'@client' ).should == @client
  end
  
  it 'should return photos for the current photoset' do 
    set = mock('photo set')
    Flickr::Photo.should_receive( :api_query ).with( 'photosets.getPhotos', @client, :photoset_id => '5').and_return( set )
    @photoset.photos.should == set
  end
end