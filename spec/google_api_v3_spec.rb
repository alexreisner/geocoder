# encoding: utf-8
require 'geocoder'
require 'pp'

describe "GoogleAPIV3" do
  before(:all) do
    Geocoder::Configuration.lookup = :google_api_v3
  end
  
  it "should search" do
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    result.address_components_of_type(:sublocality).first['long_name'].should == "Manhattan"
  end
  
  it "should find the direction between 2 points" do
    origin_point = '4 Pennsylvania Plaza, New York, NY 10001 (Madison Square Garden)'
    destination_point = '100 8th Avenue, New York, NY, United States'
    
    directions = Geocoder.direction(origin_point, destination_point)
    
    directions.should_not be_nil
    directions.should_not be_empty
  
    found_direction = directions.first
    found_direction.should be_kind_of(Geocoder::DirectionResult::GoogleApiV3)
    
    found_direction.summary.should == '7th Ave'
    found_direction.legs.should have(1).item
    
    leg = found_direction.legs.first
    leg.distance.should == 1854
    leg.duration.should == 187
  end
end