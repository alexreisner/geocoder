require 'geocoder'
require 'optparse'

module Geocoder
  class Cli

    def self.run(args, out = STDOUT)
      url_only = false

      OptionParser.new{ |opts|
        opts.banner = "Usage:\n    geocode [options] location"
        opts.separator "\nOptions: "

        opts.on("-k <key>", "--key <key>",
          "Key for geocoding API (optional for most)") do |key|
          Geocoder::Configuration.api_key = key
        end

        opts.on("-l <language>", "--language <language>",
          "Language of output (see API docs for valid choices)") do |language|
          Geocoder::Configuration.language = language
        end

        lookups = Geocoder.valid_lookups - [:freegeoip]
        opts.on("-s <service>", lookups, "--service <service>",
          "Geocoding service: #{lookups.join(', ')}") do |service|
          Geocoder::Configuration.lookup = service.to_sym
        end

        opts.on("-t <seconds>", lookups, "--timeout <seconds>",
          "Maximum number of seconds to wait for API response") do |timeout|
          Geocoder::Configuration.timeout = timeout.to_i
        end

        opts.on("-u", "--url", "Print URL for API instead of result") do
          url_only = true
        end

        opts.on_tail("-v", "--version", "Print version number") do
          puts "Geocoder #{Geocoder.version}"
          exit
        end

        opts.on_tail("-h", "--help", "Print this help") do
          puts opts
          exit
        end
      }.parse!(args)

      query = args.join(" ")

      if query == ""
        out << "Please specify a location to search for.\n"
        exit 1
      end

      if url_only
        out << Geocoder.send(:lookup).send(:query_url, query) + "\n"
        exit 0
      end

      if (result = Geocoder.search(query).first)
        out << result.coordinates.join(',') + "\n"
        out << result.address + "\n"
        exit 0
      else
        out << "Location '#{query}' not found.\n"
        exit 2
      end
    end
  end
end
