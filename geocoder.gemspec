# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'geocoder'
require 'date'

Gem::Specification.new do |s|
  s.name        = "geocoder"
  s.version     = Geocoder.version
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alex Reisner"]
  s.email       = ["alex@alexreisner.com"]
  s.homepage    = "http://www.rubygeocoder.com"
  s.date        = Date.today.to_s
  s.summary     = "Complete geocoding solution for Ruby."
  s.description = "Provides object geocoding (by street or IP address), reverse geocoding (coordinates to street address), and distance queries for ActiveRecord and Mongoid. Designed for Rails but works with other Rack frameworks too."
  s.files       = `git ls-files`.split("\n") - %w[geocoder.gemspec Gemfile init.rb]
  s.require_paths = ["lib"]
  s.executables = ["geocode"]
end
