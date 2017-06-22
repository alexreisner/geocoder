# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'date'
require "geocoder/version"

Gem::Specification.new do |s|
  s.name        = "geocoder"
  s.required_ruby_version = '>= 1.9.3'
  s.version     = Geocoder::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alex Reisner"]
  s.email       = ["alex@alexreisner.com"]
  s.homepage    = "http://www.rubygeocoder.com"
  s.date        = Date.today.to_s
  s.summary     = "Complete geocoding solution for Ruby."
  s.description = "Provides object geocoding (by street or IP address), reverse geocoding (coordinates to street address), distance queries for ActiveRecord and Mongoid, result caching, and more. Designed for Rails but works with Sinatra and other Rack frameworks too."
  s.files       = Dir['CHANGELOG.md', 'LICENSE', 'README.md', 'examples/**/*', 'lib/**/*', 'bin/*']
  s.require_paths = ["lib"]
  s.executables = ["geocode"]
  s.license     = 'MIT'

  s.metadata = {
    'source_code_uri' => 'https://github.com/alexreisner/geocoder',
    'changelog_uri'   => 'https://github.com/alexreisner/geocoder/blob/master/CHANGELOG.md'
  }
end
