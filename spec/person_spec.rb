require File.dirname(__FILE__) + '/spec_helper.rb'

describe Flickr::Person do
  before( :each ) do 
    @client = mock( 'Flickr::Client' )
  end
  
  describe 'when finding a person' do 
    before( :each ) do
      @find_user_xml = Hpricot.parse( '<rsp stat="ok"><user nsid="66273938@N00" id="66273938@N00"><username>Ennoia</username></user></rsp>' )
      @person_xml = Hpricot.parse( '<rsp stat="ok"><person nsid="12037949754@N01" isadmin="0" ispro="0" iconserver="122" iconfarm="1">
	<username>bees</username><realname>Cal Henderson</realname><mbox_sha1sum>eea6cd28e3d0003ab51b0058a684d94980b727ac</mbox_sha1sum>
	<location>Vancouver, Canada</location><photosurl>http://www.flickr.com/photos/bees/</photosurl><profileurl>http://www.flickr.com/people/bees/</profileurl> 
	<photos><firstdate>1071510391</firstdate><firstdatetaken>1900-09-02 09:11:24</firstdatetaken><count>449</count></photos></person></rsp>')
      
      @person = mock( 'Flickr::Person' )
    end
    
    it 'should find a person by email address' do 
      @client.should_receive( :request ).with( 'people.findByEmail' , :find_email => 'foo@bar.com' ).and_return( @find_user_xml )
      Flickr::Person.should_receive( :find_by_id ).with( '66273938@N00', @client ).and_return( @person )
      Flickr::Person.find( 'foo@bar.com' , @client ).should == @person
    end
    
    it 'should find a person by username' do 
      @client.should_receive( :request ).with( 'people.findByUsername' , :username => 'ennoia' ).and_return( @find_user_xml )
      Flickr::Person.should_receive( :find_by_id ).with( '66273938@N00', @client ).and_return( @person )
      Flickr::Person.find( 'ennoia' , @client ).should == @person
    end
  
    it 'should return nil if no person was found' do 
      @client.should_receive( :request ).and_raise( Flickr::RequestError.new( '1', 'Not found') )
      Flickr::Person.find( 'sdfsdfsd', @client ).should == nil
    end
    
    it 'should raise an exception if any other error is encountered' do 
      @client.should_receive( :request ).and_raise( Flickr::RequestError.new( '101', 'Not found') )
      proc { Flickr::Person.find( 'sdfsdfsd', @client ) }.should raise_error( Flickr::RequestError ) 
    end
    
    it 'should return nil if something invalid is passed in (non string)' do 
      Flickr::Person.find(nil, @client).should == nil
    end
    
    it 'should find a user by the flickr userid' do 
      @client.should_receive( :request ).with( 'people.getInfo', :user_id => '66273938@N00' ).and_return( @person_xml )
      Flickr::Person.should_receive( :new ).with( @person_xml.at('person'), @client ).and_return( @person )
      Flickr::Person.find_by_id( '66273938@N00' , @client ).should == @person
    end
    
    it 'should return nil if no person was found by id' do 
      @client.should_receive( :request ).and_raise( Flickr::RequestError.new( '1', 'Not found') )
      Flickr::Person.find_by_id( 'sdfsdfsd', @client ).should == nil
    end
  end
end

describe Flickr::Person do
  before( :each ) do 
    @client = mock( 'Flickr::Client' )
    user_xml = Hpricot.parse( '<rsp stat="ok"><person nsid="12037949754@N01" isadmin="0" ispro="0" iconserver="122" iconfarm="1">
	<username>bees</username><realname>Cal Henderson</realname><mbox_sha1sum>eea6cd28e3d0003ab51b0058a684d94980b727ac</mbox_sha1sum>
	<location>Vancouver, Canada</location><photosurl>http://www.flickr.com/photos/bees/</photosurl><profileurl>http://www.flickr.com/people/bees/</profileurl> 
	<photos><firstdate>1071510391</firstdate><firstdatetaken>1900-09-02 09:11:24</firstdatetaken><count>449</count></photos></person></rsp>')
    @person = Flickr::Person.new( user_xml.at('person'), @client )
  end

  it 'should include proxy' do 
    Flickr::Photo.included_modules.include?( Flickr::Proxy ).should == true
  end
  
  it 'should set the id' do
    @person.id.should == '12037949754@N01'
  end

  it 'should use the passed in client' do 
    @person.instance_variable_get( :'@client' ).should == @client
  end
  
  it 'should return the users photos' do 
    photos = mock( 'photos' )
    Flickr::Photo.should_receive( :api_query ).with( 'people.getPublicPhotos', @client, :user_id => '12037949754@N01', :per_page => 2 ).and_return( photos )
    @person.photos( :per_page => 2).should == photos    
  end
  
  it 'should return the users favorites' do 
    photos = mock( 'photos' )
    Flickr::Photo.should_receive( :api_query ).with( 'favorites.getPublicList', @client, :user_id => '12037949754@N01', :per_page => 2 ).and_return( photos )
    @person.favorites( :per_page => 2).should == photos    
  end
  
  it 'should return the users photosets' do 
    photosets = mock( 'photosets' )
    Flickr::PhotoSet.should_receive( :api_query ).with( 'photosets.getList', @client, :user_id => '12037949754@N01' ).and_return( photosets )
    @person.photosets.should == photosets    
  end
end

