require File.dirname(__FILE__) + '/spec_helper.rb'

class Flickr::ProxyTest
  include Flickr::Proxy
end

describe Flickr::ProxyTest do
  
  describe 'when dealing with attributes' do 
    before( :each ) do 
      @client = mock( 'Flickr::Client' )
      @xml = Hpricot.parse( '<doc><proxytest id="2636" var1="test" foo="bar" /></doc>' ).at( 'proxytest' )
    end

    it 'should set the attributes' do 
      proxy = Flickr::ProxyTest.new( @xml, @client )
      proxy.id.should == "2636"
      proxy.var1.should == "test"
      proxy.foo.should == "bar"
    end
    
    it 'should set the client' do 
      proxy = Flickr::ProxyTest.new( @xml, @client )
      proxy.instance_variable_get( :'@client' ).should == @client
    end
  end
  
  describe 'when calling api_query' do 
    it 'should make a request to get photosets for the current user id' do 
      @client.should_receive( :request ).with( 'photosets.getList', { :user_id => '66273938@N00' } ).and_return( stub('hpricot result', :search => [] ) ) 
      Flickr::ProxyTest.api_query( 'photosets.getList', @client, :user_id => '66273938@N00' )
    end
    
    it 'should return PhotoSet objects created with the returned xml for each photo' do 
      result = mock( 'Hpricot XML Result')
      test1_xml,test2_xml = mock('hpricot xml'), mock('hpricot xml')
      test1, test2 = mock('test'), mock('photo')
      
      @client.should_receive( :request ).and_return( result )
      result.should_receive( :search ).with( 'proxytest' ).and_return( [test1_xml, test2_xml] )
      
      Flickr::ProxyTest.should_receive( :new ).with( test1_xml, @client ).and_return( test1 )
      Flickr::ProxyTest.should_receive( :new ).with( test2_xml, @client ).and_return( test2 )
      
      Flickr::ProxyTest.api_query( 'proxytest.getList', @client ).should == [test1,test2]
    end
  end
end