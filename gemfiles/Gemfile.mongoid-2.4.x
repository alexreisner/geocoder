source "http://rubygems.org"

gemspec :path => '..'

group :development, :test do
  gem 'rake'
  gem 'mongoid', '2.4.11'
  gem 'bson_ext', :platforms => :ruby
  gem 'geoip'

  gem 'rails'

  platforms :jruby do
    gem 'jruby-openssl'
  end
end
