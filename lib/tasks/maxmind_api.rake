require 'maxmind_database_api'

# Copied (and moved into different ns) most of maxmind.rake with minimal required adjustments.

namespace :geocoder do
  namespace :maxmind_api do
    namespace :geolite do

      desc "Download and load/refresh MaxMind GeoLite City data"
      task load: [:download, :extract, :insert]

      desc "Download MaxMind GeoLite City data"
      task download: :environment do # critical for loading own monkey patches
        p = MaxmindTaskProtected.check_for_package!
        MaxmindTaskProtected.download!(p, dir: ENV['DIR'] || "tmp/")
      end

      desc "Extract (unzip) MaxMind GeoLite City data"
      task :extract do
        p = MaxmindTaskProtected.check_for_package!
        MaxmindTaskProtected.extract!(p, dir: ENV['DIR'] || "tmp/")
      end

      desc "Load/refresh MaxMind GeoLite City data"
      task insert: [:environment] do
        p = MaxmindTaskProtected.check_for_package!
        MaxmindTaskProtected.insert!(p, dir: ENV['DIR'] || "tmp/")
      end
    end
  end
end

module MaxmindTaskProtected
  extend self

  def check_for_package!
    return 'city'
    # if %w[city country].include?(p = ENV['PACKAGE'])
    #   return p
    # else
    #   puts "Please specify PACKAGE=city or PACKAGE=country"
    #   exit
    # end
  end

  def download!(package, options = {})
    p = "geolite_#{package}_csv".intern
    Geocoder::MaxmindDatabaseApi.download(p, options[:dir])
  end

  def extract!(package, options = {})
    begin
      require 'zip'
    rescue LoadError
      puts "Please install gem: rubyzip (>= 1.0.0)"
      exit
    end
    require 'fileutils'
    p = "geolite_#{package}_csv".intern
    archive_filename = Geocoder::MaxmindDatabaseApi.archive_filename(p)
    Zip::File.open(File.join(options[:dir], archive_filename)).each do |entry|
      filepath = File.join(options[:dir], entry.name)
      if File.exist? filepath
        warn "File already exists (#{entry.name}), skipping"
      else
        FileUtils.mkdir_p(File.dirname(filepath))
        entry.extract(filepath)
      end
    end
  end

  def insert!(package, options = {})
    p = "geolite_#{package}_csv".intern
    Geocoder::MaxmindDatabaseApi.insert(p, options[:dir])
  end
end
