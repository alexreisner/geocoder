def klass
  class_name = ENV['CLASS'] || ENV['class']
  raise "Please specify a CLASS (model)" unless class_name
  Object.const_get(class_name)
end

namespace :geocode do

  desc "Geocode all objects without coordinates."
  task :all => :environment do
    klass.not_geocoded.each do |obj|
      obj.geocode; obj.save
    end
  end
  
  desc "Geocode objects without coordinates with a limit."
  task :with_limit => :environment do
    limit = ENV['LIMIT'] || ENV['limit']
    raise "Please specify a LIMIT" unless limit

    klass.not_geocoded.limit(limit).each do |obj|
      puts "Processing #{obj.class.name} ID##{obj.id}"
      obj.geocode; obj.save
    end
  end

end
