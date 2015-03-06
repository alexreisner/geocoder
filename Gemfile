source "https://rubygems.org"

group :development, :test do
  gem 'rake'
  gem 'mongoid', '2.6.0'
  gem 'bson_ext', platforms: :ruby
  gem 'geoip'
  gem 'rubyzip'
  gem 'rails'
  gem 'test-unit' # needed for Ruby >=2.2.0

  gem 'byebug', platforms: :mri

  platforms :jruby do
    gem 'jruby-openssl'
    gem 'jgeoip'
  end

  platforms :rbx do
    gem 'rubysl', '~> 2.0'
    gem 'rubysl-test-unit'
  end
end

group :test do
  platforms :ruby do
    gem 'pg'
    gem 'sqlite3'
    gem 'mysql2'
  end

  platforms :jruby do
    gem 'activerecord-jdbcpostgresql-adapter'
  end
end

gemspec
