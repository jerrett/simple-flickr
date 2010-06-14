require File.dirname(__FILE__) + '/spec_helper.rb'

describe Flickr::Group do 
  before( :each ) do 
    @client = mock( 'Flickr::Client' )
    @xml = Hpricot.parse( '<group id="34427465497@N01" iconserver="1" lang="en-us" ispoolmoderated="0"><name>GNEverybody</name><description>The group for GNE players</description><members>69</members><privacy>3</privacy><throttle count="10" mode="month" remaining="3"/></group>' )
    @group = Flickr::Group.new( @xml.at('group'), @client )
  end

  it 'should include proxy' do 
    Flickr::Group.included_modules.include?( Flickr::Proxy ).should == true
  end

  it 'should use the passed in client' do 
    @group.instance_variable_get( :'@client' ).should == @client
  end
  
  it 'should return photos in the group' do 
    photos = mock('photos')
    Flickr::Photo.should_receive( :api_query ).with( 'photos.search', @client, :group_id => '34427465497@N01' ).and_return( photos )
    @group.photos.should == photos
  end

  it 'it should find the group by the id' do 
    @client.should_receive( :request ).with( 'groups.getInfo', :group_id => '34427465497@N01' ).and_return( @xml )
    group = Flickr::Group.find_by_id( '34427465497@N01', @client )
    group.id.should == '34427465497@N01'
    group.name.should == 'GNEverybody'
    group.should be_instance_of( Flickr::Group )
  end
  
  it 'should return nil if something invalid is passed in (non string)' do 
    Flickr::Group.find_by_id(nil, @client).should == nil
  end
end
