def klass
  class_name = ENV['CLASS'] || ENV['class']
  raise "Please specify a CLASS (model)" unless class_name
  Object.const_get(class_name)
end

namespace :geocode do

  desc "Geocode all objects without coordinates."
  task :all => :environment do
    klass.not_geocoded.each do |obj|
      obj.fetch_coordinates!
    end
  end
end
