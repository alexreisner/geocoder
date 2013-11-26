require 'test_helper'
require 'geocoder/pr_geohash'

class PrGeoHashTests < Test::Unit::TestCase
  def test_decode
    {
      'c216ne' => [[45.3680419921875, -121.70654296875], [45.37353515625, -121.695556640625]],
      'C216Ne' => [[45.3680419921875, -121.70654296875], [45.37353515625, -121.695556640625]],
      'dqcw4'  => [[39.0234375, -76.552734375], [39.0673828125, -76.5087890625]],
      'DQCW4'  => [[39.0234375, -76.552734375], [39.0673828125, -76.5087890625]]
    }.each do |hash, latlng|
      assert_equal GeoHash.decode(hash), latlng
    end
  end
  
  def test_encode
    {
      [ 45.37,      -121.7      ] => 'c216ne',
      [ 47.6062095, -122.3320708] => 'c23nb62w20sth',
      [ 35.6894875,  139.6917064] => 'xn774c06kdtve',
      [-33.8671390,  151.2071140] => 'r3gx2f9tt5sne',
      [ 51.5001524,   -0.1262362] => 'gcpuvpk44kprq'
    }.each do |latlng, hash|
      assert_equal GeoHash.encode(latlng[0], latlng[1], hash.length), hash
    end
  end
  
  def test_neighbors
    {
      'dqcw5' => ["dqcw7", "dqctg", "dqcw4", "dqcwh", "dqcw6", "dqcwk", "dqctf", "dqctu"],
      'xn774c' => ['xn774f','xn774b','xn7751','xn7749','xn774d','xn7754','xn7750','xn7748'],
      'gcpuvpk' => ['gcpuvps','gcpuvph','gcpuvpm','gcpuvp7','gcpuvpe','gcpuvpt','gcpuvpj','gcpuvp5'],
      'c23nb62w' => ['c23nb62x','c23nb62t','c23nb62y','c23nb62q','c23nb62r','c23nb62z','c23nb62v','c23nb62m']
    }.each do |geohash, neighbors|
      assert_equal GeoHash.neighbors(geohash).sort, neighbors.sort
    end
  end
  
  def test_adjacent
    {
      ["dqcjq", :top]    => 'dqcjw',
      ["dqcjq", :bottom] => 'dqcjn',
      ["dqcjq", :left]   => 'dqcjm',
      ["dqcjq", :right]  => 'dqcjr'
    }.each do |position, hash|
      assert_equal GeoHash.adjacent(*position), hash
    end
  end
end