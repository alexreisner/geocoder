require 'geocoder'
require 'optparse'

module Geocoder
  class Cli

    def self.run(args, out = STDOUT)
      show_url  = false
      show_json = false

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

        opts.on("-j", "--json", "Print API's raw JSON response") do
          show_json = true
        end

        opts.on("-u", "--url", "Print URL for API instead of result") do
          show_url = true
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
        out << "Please specify a location (run `geocode -h` for more info).\n"
        exit 1
      end

      if show_url and show_json
        out << "You can only specify one of -j and -u.\n"
        exit 2
      end

      if show_url
        out << Geocoder.send(:lookup).send(:query_url, query) + "\n"
        exit 0
      end

      if show_json
        out << Geocoder.send(:lookup).send(:fetch_raw_data, query) + "\n"
        exit 0
      end

      if (result = Geocoder.search(query).first)
        lines = [
          ["Latitude",       :latitude],
          ["Longitude",      :longitude],
          ["Full address",   :address],
          ["City",           :city],
          ["State/province", :state],
          ["Postal code",    :postal_code],
          ["Country",        :country],
        ]
        lines.each do |line|
          out << (line[0] + ": ").ljust(18) + result.send(line[1]).to_s + "\n"
        end
        exit 0
      else
        out << "Location '#{query}' not found.\n"
        exit 1
      end
    end
  end
end
