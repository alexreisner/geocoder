# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "rails-geocoder"
  s.version     = File.read(File.join(File.dirname(__FILE__), 'VERSION'))
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alex Reisner"]
  s.email       = ["alex@alexreisner.com"]
  s.homepage    = "http://github.com/alexreisner/geocoder"
  s.date        = Date.today.to_s
  s.summary     = "Complete geocoding solution for Ruby."
  s.description = "Provides object geocoding (by street or IP address), reverse geocoding (coordinates to street address), and distance calculations for geocoded objects. Designed for Rails but works with other frameworks too."
  s.files       = `git ls-files`.split("\n") - %w[rails-geocoder.gemspec Gemfile init.rb]
  s.require_paths = ["lib"]
end
