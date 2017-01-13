namespace :geocode do
  desc "Geocode all objects without coordinates."
  task :all => :environment do
    class_name = ENV['CLASS'] || ENV['class']
    sleep_timer = ENV['SLEEP'] || ENV['sleep']
    batch = ENV['BATCH'] || ENV['batch']
    reverse = ENV['REVERSE'] || ENV['reverse']
    raise "Please specify a CLASS (model)" unless class_name
    klass = class_from_string(class_name)
    batch = (batch.to_i unless batch.nil?) || 1000
    orm = (klass < Geocoder::Model::Mongoid) ? 'mongoid' : 'active_record'

    scope = reverse? ? klass.not_reverse.geocoded : klass.reverse.geocoded
    if orm == 'mongoid'
      scope.each do |obj|
        geocode_record(obj, reverse?)
      end
    elsif orm == 'active_record'
      scope.find_each(batch_size: batch) do |obj|
        geocode_record(obj, reverse?)
      end
    end

    def geocode_record(obj, reverse=false)
      reverse ? obj.reverse_geocode : obj.geocode
      obj.save
      sleep(sleep_timer.to_f) unless sleep_timer.nil?
    end

    def reverse?
      reverse.to_s.downcase == 'true'
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
