source "https://rubygems.org"

group :development, :test do
  gem 'rake'
  gem 'mongoid', '2.6.0'
  gem 'bson_ext', :platforms => :ruby
  gem 'geoip'
  gem 'rubyzip'
  gem 'rails'
  gem 'test-unit' # needed for Ruby >=2.2.0

  # i18n gem >=0.7.0 does not work with Ruby 1.9.2
  gem 'i18n', '0.6.1', :platforms => [:mri_19]

  gem 'debugger', :platforms => [:mri_19]
  gem 'byebug', :platforms => [:mri_20, :mri_21, :mri_22]

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
