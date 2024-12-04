source "https://rubygems.org"

group :development, :test do
  gem 'rake'
  gem 'mongoid'
  gem 'geoip'
  gem 'rubyzip'
  gem 'rails', '~>5.1.0'
  gem 'test-unit' # needed for Ruby >=2.2.0
  gem 'ip2location_ruby'

  platforms :jruby do
    gem 'jruby-openssl'
    gem 'jgeoip'
  end
end

group :test do
  platforms :ruby, :mswin, :mingw do
    gem 'sqlite3'
    gem 'sqlite_ext'
  end

  gem 'webmock'

  platforms :ruby do
    gem 'pg', '~> 1.1.4'
    gem 'mysql2', '~> 0.5.4'
  end

  platforms :jruby do
    gem 'jdbc-mysql'
    gem 'jdbc-sqlite3'
    gem 'activerecord-jdbcpostgresql-adapter'
  end
end

gemspec
