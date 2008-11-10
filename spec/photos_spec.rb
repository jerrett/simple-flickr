require File.dirname(__FILE__) + '/spec_helper.rb'

describe Flickr::Photos do
  before( :each ) do 
    @client = mock( 'Flickr::Client' )
    @photos_xml = Hpricot.parse( '<photos page="2" pages="89" perpage="10" total="881"><photo id="2636" owner="47058503995@N01" farm="1" secret="a123456" server="2" title="test_04" ispublic="1" isfriend="0" isfamily="0" /></photos>' )
    @photo = mock( 'photo' )
    Flickr::Photo.stub!( :new ).and_return( @photo )
    
    @photos = Flickr::Photos.new( @photos_xml.at('photos'), @client )
  end
  
  it 'should implement size' do
    @photos.size.should == 1
  end
  
  it 'should implement each' do 
    @photos.each { |photo| photo }.should == [@photo]
  end
  
  it 'should implement empty?' do 
    @photos.empty?.should == false
  end

  it 'should implement pagination methods' do
    @photos.offset.should == 10
    @photos.current_page.should == 2
    @photos.previous_page.should == 1
    @photos.next_page.should == 3
    @photos.total_entries.should == 881
    @photos.total_pages.should == 89
  end
end

describe Flickr::Photos do
   it 'should create a collection of photos from passed in xml' do 
    client = mock( 'Flickr::Client' )
    photos_xml = Hpricot.parse( '<photos page="2" pages="89" perpage="10" total="881"><photo id="2636" owner="47058503995@N01" farm="1" secret="a123456" server="2" title="test_04" ispublic="1" isfriend="0" isfamily="0" /><photo id="2637" owner="47058503995@N01" farm="1" secret="a123456" server="2" title="test_05" ispublic="1" isfriend="0" isfamily="0" /></photos>' )
    photos = Flickr::Photos.new( photos_xml.at('photos'), client )
   
    photos[0].id.should == '2636'
    photos[0].title.should == 'test_04'
    photos[0].should be_kind_of(Flickr::Photo)
    
    photos[1].id.should == '2637'
  end
end