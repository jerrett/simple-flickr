require File.dirname(__FILE__) + '/spec_helper.rb'

describe Flickr::Client do
  before( :each ) do 
    @flickr = Flickr::Client.new( 'my-api-key' )
  end
  
  it 'should make a request to a flickr method with no arguments' do 
    @flickr.should_receive( :open ).with( Flickr::Client::REST_ENDPOINT + '?api_key=my-api-key&method=flickr.test.echo' ).and_return( VALID_FLICKR_RESPONSE )
    @flickr.request( 'test.echo' )
  end 

  it 'should make a request to a flickr method with arguments passed' do 
    @flickr.should_receive( :open ).with( Flickr::Client::REST_ENDPOINT + '?api_key=my-api-key&method=flickr.favorites.getList&per_page=4&user_id=123456789N00' ).and_return( VALID_FLICKR_RESPONSE )
    @flickr.request( 'favorites.getList', :user_id => '123456789N00', :per_page => 4 )
  end
  
  [Errno::ETIMEDOUT, OpenURI::HTTPError.new(nil,nil), Errno::ECONNRESET, SocketError, Errno::ECONNREFUSED].each do |e| 
    it "should raise an appropriate error if open-uri raises #{e}" do
      @flickr.should_receive( :open ).and_raise( e )
      proc { @flickr.request( 'test.echo' ) }.should raise_error( Flickr::RequestError )
    end
  end

  it 'should raise an appropriate error if something goes wrong with the request' do 
    @flickr.should_receive( :open ).and_return( INVALID_FLICKR_RESPONSE )
    proc { @flickr.request( 'test.echo' ) }.should raise_error( Flickr::RequestError )
  end
  
  it 'should cache requests returning the correct result and not make uneccesary calls to flickr' do 
    @flickr.should_receive( :open ).once.and_return( VALID_FLICKR_RESPONSE )
    
    response = Hpricot.XML( VALID_FLICKR_RESPONSE.read ).at( 'rsp' )
    @flickr.request( 'favorites.getList', :user_id => '123456789N00', :per_page => 4 ).to_s.should == response.to_s
    @flickr.request( 'favorites.getList', :user_id => '123456789N00', :per_page => 4 ).to_s.should == response.to_s
  end
  
  it 'should request a user passing self in as the client' do 
    user = mock('flickr user')
    Flickr::Person.should_receive( :find ).with( 'ennoia', @flickr ).and_return( user )
    @flickr.person( 'ennoia' ).should == user
  end

  it 'should request a photo passing self in as the client' do
    photo = mock('flickr photo')
    Flickr::Photo.should_receive( :find ).with( 'myphoto', @flickr ).and_return( photo )
    @flickr.photo( 'myphoto' ).should == photo
  end
end


