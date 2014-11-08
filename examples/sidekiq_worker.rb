# This class implements a Sidekiq worker for performing geocoding
# asynchronously. Do something like this in your controller:
#
# if @object.save
#   GeocoderWorker.perform_async(@object.id)
# end
#
class GeocoderWorker
  include Sidekiq::Worker

  def perform(object_id)
    object = Object.find(object_id)
    object.geocode
    object.save!
  end
end
