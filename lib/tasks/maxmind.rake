require 'maxmind_database'

namespace :geocoder do
  namespace :maxmind do
    namespace :geolite_city do

      desc "Download and load/refresh MaxMind GeoLite City data"
      task load: [:download, :extract, :insert]

      desc "Download MaxMind GeoLite City data"
      task :download do
        dir = ENV['DIR'] || "tmp/"
        Geocoder::MaxmindDatabase.download(:geolite_city_csv, dir)
        # TODO: confirm data was fetched properly
      end

      desc "Extract (unzip) MaxMind GeoLite City data"
      task :extract do
        dir = ENV['DIR'] || "tmp/"
        filename = Geocoder::MaxmindDatabase.archive_filename(:geolite_city_csv)
        `unzip -o #{File.join(dir, filename)} -d #{dir}` # TODO: make platform independent, overwrite w/out confirm
        # TODO: confirm data was unzipped properly
      end

      desc "Load/refresh MaxMind GeoLite City data"
      task insert: [:environment] do
        dir = ENV['DIR'] || "tmp/"
        Geocoder::MaxmindDatabase.insert(:geolite_city_csv, dir)
      end
    end
  end
end
