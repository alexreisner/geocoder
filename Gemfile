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
  platforms :ruby, :mswin, :mingw do
    gem 'sqlite3'
    gem 'sqlite_ext', '~> 1.5.0'
  end

  gem 'webmock'

  platforms :ruby do
    gem 'pg', '~> 0.11'
    gem 'mysql2', '~> 0.3.11'
  end

  platforms :jruby do
    gem 'jdbc-mysql'
    gem 'jdbc-sqlite3'
    gem 'activerecord-jdbcpostgresql-adapter', '~> 1.3.0'
  end
end

gemspec
