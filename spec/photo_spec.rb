require File.dirname(__FILE__) + '/spec_helper.rb'

describe Flickr::Photo do
  before( :each ) do 
    @client = mock( 'Flickr::Client' )
    @xml = Hpricot.parse( '<photos page="2" pages="89" perpage="10" total="881"><photo id="2636" owner="47058503995@N01" farm="1" secret="a123456" server="2" title="test_04" ispublic="1" isfriend="0" isfamily="0" /></photos>' )
    @photo = Flickr::Photo.new( @xml.at('photo'), @client )
  end

  it 'should include proxy' do 
    Flickr::Photo.included_modules.include?( Flickr::Proxy ).should == true
  end
  
  it 'should use the passed in client' do 
    @photo.instance_variable_get( :'@client' ).should == @client
  end

  it 'should fetch "person" when it is requested' do
    @photo.should_receive(:owner).and_return('owner_id')
    Flickr::Person.should_receive(:find_by_id).with('owner_id', @client).and_return('person')
    @photo.person.should == 'person'
  end

  it 'should fetch a single photo on a call to Photo.find' do
    @photo_data = mock('photo', :at => 'photodata')
    @client.should_receive(:request).with('photos.getInfo', :photo_id => 'myphoto').and_return(@photo_data)
    Flickr::Photo.should_receive(:new).with('photodata', @client).and_return('my photo object')
    Flickr::Photo.find('myphoto', @client)
  end
  
  it 'should return the url of the image for the requested size' do
    @photo.url.should == 'http://farm1.static.flickr.com/2/2636_a123456.jpg'
    @photo.url( 'small' ).should == 'http://farm1.static.flickr.com/2/2636_a123456_m.jpg'
  end
  
  it 'should implement <=> based on id' do 
    @photo
    photo2 = mock( 'photo', :id => '2636' )
    photo3 = mock( 'photo', :id => '2637' )
    photo4 = mock( 'photo', :id => '2635' )
    
    (@photo <=> photo2).should == 0
    (@photo <=> photo3).should == -1
    (@photo <=> photo4).should == 1
  end
  
  it 'should include comparable' do
    Flickr::Photo.included_modules.include?( Comparable ).should == true
  end
  
  it 'should create a new Photos collection with the results of the photos node in the returned xml' do 
    @client.should_receive( :request ).with( 'person.listPhotos', :foo => 'bar' ).and_return( @xml )
    Flickr::Photos.should_receive( :new ).with( @xml.at('photos'), @client )
    Flickr::Photo.api_query(  'person.listPhotos', @client, :foo => 'bar')  
  end
  
  it 'should create a new Photos collection with the results of the photosets node in the returned xml' do 
    photosets_xml = Hpricot.parse( '<photosets page="2" pages="89" perpage="10" total="881"><photo id="2636" owner="47058503995@N01" farm="1" secret="a123456" server="2" title="test_04" ispublic="1" isfriend="0" isfamily="0" /></photosets>' )
  
    @client.should_receive( :request ).with( 'person.listPhotos', :foo => 'bar' ).and_return( photosets_xml )
    Flickr::Photos.should_receive( :new ).with( photosets_xml.at('photoset'), @client )
    Flickr::Photo.api_query(  'person.listPhotos', @client, :foo => 'bar')  
  end
end