# encoding: utf-8
require 'geocoder'
require 'pp'

describe "GoogleAPIV3" do
  ORIGIN_POINT = '440 8th Avenue, New York, NY, United States' # Madison Square Garden
  DESTINATION_POINT = '100 8th Avenue, New York, NY, United States'
  MIDDLE_POINT = '244 11th Avenue, New York, NY, United States'
  
  LONG_JOURNEY_ORIGIN_POINT = '1229 Wisconsin Avenue Northwest, Washington, DC, United States'
  LONG_JOURNEY_DESTINATION_POINT = '440 8th Avenue, New York, NY, United States'
  
  before(:all) do
    Geocoder::Configuration.lookup = :google_api_v3
  end
  
  it "should search" do
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    result.address_components_of_type(:sublocality).first['long_name'].should == "Manhattan"
  end
  
  it "should find the route between 2 points" do
    routes = Geocoder.routes_between([ORIGIN_POINT, DESTINATION_POINT])
    
    routes.should_not be_nil
    routes.should have(1).item # no alternative
  
    found_route = routes.first
    found_route.should be_kind_of(Geocoder::RouteResult::GoogleApiV3)
    
    found_route.summary.should == '9th Ave'
    found_route.parts.should have(1).item
    
    part = found_route.parts.first
    part.distance.should == 2182
    part.duration.should == 305
  end

  # ----------------------------------------------------------------

  it "should provide the viewport bounding box of a route" do
    routes = Geocoder.routes_between([ORIGIN_POINT, DESTINATION_POINT])
    
    found_route = routes.first
    bounding_box = found_route.bounding_box
    
    # I think in the calcultation module, the order is different
    # north-east
    bounding_box[0].should == 40.75273000000001
    bounding_box[1].should == -73.99395000000001
    
    # south-west
    bounding_box[2].should == 40.739750
    bounding_box[3].should == -74.005160
  end

  # ----------------------------------------------------------------

  it "should find altenatives routes" do
    routes = Geocoder.routes_between([ORIGIN_POINT, DESTINATION_POINT], {:alternatives => true})
    
    routes.should have(3).items
    
    routes[0].parts[0].distance.should == 2182
    routes[1].parts[0].distance.should == 2691
    routes[2].parts[0].distance.should == 2746
  end
  
  # ----------------------------------------------------------------
  
  it "should find a route with multipoints" do
    routes = Geocoder.routes_between([ORIGIN_POINT, MIDDLE_POINT, DESTINATION_POINT])
    
    routes.should have(1).item
    found_route = routes.first
    
    found_route.parts.should have(2).items
    
    found_route.parts[0].distance.should == 1394
    found_route.parts[1].distance.should == 1882
  end
  
  # ----------------------------------------------------------------
  
  it "should avoid tolls or highways" do
    # with highways or tolls
    routes = Geocoder.routes_between([LONG_JOURNEY_ORIGIN_POINT, LONG_JOURNEY_DESTINATION_POINT])
    found_route = routes.first
    found_route.parts[0].distance.should == 373477
    
    # without highway
    routes = Geocoder.routes_between([LONG_JOURNEY_ORIGIN_POINT, LONG_JOURNEY_DESTINATION_POINT], :avoid => :highways)
    found_route = routes.first
    found_route.parts[0].distance.should == 384296
    
    # without toll
    routes = Geocoder.routes_between([LONG_JOURNEY_ORIGIN_POINT, LONG_JOURNEY_DESTINATION_POINT], :avoid => :tolls)
    found_route = routes.first
    found_route.parts[0].distance.should == 383729
  end
end