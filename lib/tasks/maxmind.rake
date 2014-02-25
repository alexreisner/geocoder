require 'zip'
require 'fileutils'
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
      end

      desc "Extract (unzip) MaxMind GeoLite City data"
      task :extract do
        dir = ENV['DIR'] || "tmp/"
        archive_filename = Geocoder::MaxmindDatabase.archive_filename(:geolite_city_csv)
        Zip::File.open(File.join(dir, archive_filename)).each do |entry|
          filepath = File.join(dir, entry.name)
          if File.exist? filepath
            warn "File already exists (#{entry.name}), skipping"
          else
            FileUtils.mkdir_p(File.dirname(filepath))
            entry.extract(filepath)
          end
        end
      end

      desc "Load/refresh MaxMind GeoLite City data"
      task insert: [:environment] do
        dir = ENV['DIR'] || "tmp/"
        Geocoder::MaxmindDatabase.insert(:geolite_city_csv, dir)
      end
    end
  end
end
