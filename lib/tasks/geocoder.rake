namespace :geocode do
  desc "Geocode all objects without coordinates."
  task :all => :environment do
    class_name = ENV['CLASS'] || ENV['class']
    raise "Please specify a CLASS (model)" unless class_name
    klass = class_from_string(class_name)

    klass.not_geocoded.each do |obj|
      obj.geocode; obj.save
    end
  end
end

##
# Get a class object from the string given in the shell environment.
# Similar to ActiveSupport's +constantize+ method.
#
def class_from_string(class_name)
  parts = class_name.split("::")
  constant = Object
  parts.each do |part|
    constant = constant.const_get(part)
  end
  constant
end
