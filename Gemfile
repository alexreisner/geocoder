source "https://rubygems.org"

group :development, :test do
  gem 'rake'
  gem 'mongoid', '2.6.0'
  gem 'bson_ext', :platforms => :ruby
  gem 'geoip'

  gem 'rails'

  platforms :jruby do
    gem 'jruby-openssl'
    gem 'jgeoip'
  end

  platforms :rbx do
    gem 'rubysl', '~> 2.0'
    gem 'rubysl-test-unit'
  end
end

gemspec
