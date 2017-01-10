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
    reverse = false unless reverse.to_s.downcase == 'true'
    orm = defined?(Geocoder::Model::Mongoid) ? 'mongoid' : 'active_record'

    if reverse && orm == 'mongoid'
      klass.not_reverse_geocoded.each do |obj|
        geocode_record(obj, reverse: true)
      end
    elsif reverse && orm == 'active_record'
      klass.not_reverse_geocoded.find_each(batch_size: batch) do |obj|
        geocode_record(obj, reverse: true)
      end
    elsif orm == 'mongoid'
      klass.not_geocoded.each do |obj|
        geocode_record(obj)
      end
    else
      klass.not_geocoded.find_each(batch_size: batch) do |obj|
        geocode_record(obj)
      end
    end
  end
  
  def geocode_record(obj, reverse: false)
    reverse ? obj.reverse_geocode : obj.geocode
    obj.save
    sleep(sleep_timer.to_f) unless sleep_timer.nil?
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
