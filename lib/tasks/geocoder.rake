namespace :geocode do
  desc "Geocode all objects without coordinates."
  task :all => :environment do
    class_name = ENV['CLASS'] || ENV['class']
    raise "Please specify a CLASS (model)" unless class_name
    klass = Object.const_get(class_name)

    klass.not_geocoded.each do |obj|
      obj.geocode; obj.save
    end
  end
end
