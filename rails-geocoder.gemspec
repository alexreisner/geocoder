# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "rails-geocoder"
  s.version     = File.read(File.join(File.dirname(__FILE__), 'VERSION'))
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alex Reisner"]
  s.email       = ["alex@alexreisner.com"]
  s.homepage    = "http://github.com/alexreisner/geocoder"
  s.date        = Date.today.to_s
  s.summary     = "Simple, database-agnostic geocoding and distance calculations for Rails."
  s.description = "Geocoder adds object geocoding and distance calculations to ActiveRecord models. It does not rely on proprietary database functions so finding geocoded objects in a given area is easily done using out-of-the-box MySQL, PostgreSQL, or SQLite."

  s.files         = Dir.glob("{lib,test}/*") + %w(CHANGELOG.rdoc Rakefile README.rdoc LICENSE)
  s.require_paths = ["lib"]
end

