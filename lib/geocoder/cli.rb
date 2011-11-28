require 'geocoder'
require 'optparse'

module Geocoder
  class Cli

    def self.run(args, out = STDOUT)
      show_url  = false
      show_json = false

      OptionParser.new{ |opts|
        opts.banner = "Usage:\n    geocode [options] <location>"
        opts.separator "\nOptions: "

        opts.on("-k <key>", "--key <key>",
          "Key for geocoding API (optional for most). For Google Premier use 'key client channel' separated by spaces") do |key|
          premier_key = key.split(' ')
          if premier_key.length == 3
            Geocoder::Configuration.api_key = premier_key
          else
            Geocoder::Configuration.api_key = key
          end
        end

        opts.on("-l <language>", "--language <language>",
          "Language of output (see API docs for valid choices)") do |language|
          Geocoder::Configuration.language = language
        end

        opts.on("-p <proxy>", "--proxy <proxy>",
          "HTTP proxy server to use (user:pass@host:port)") do |proxy|
          Geocoder::Configuration.http_proxy = proxy
        end

        opts.on("-s <service>", Geocoder.street_lookups, "--service <service>",
          "Geocoding service: #{Geocoder.street_lookups * ', '}") do |service|
          Geocoder::Configuration.lookup = service.to_sym
        end

        opts.on("-t <seconds>", "--timeout <seconds>",
          "Maximum number of seconds to wait for API response") do |timeout|
          Geocoder::Configuration.timeout = timeout.to_i
        end

        opts.on("-j", "--json", "Print API's raw JSON response") do
          show_json = true
        end

        opts.on("-u", "--url", "Print URL for API query instead of result") do
          show_url = true
        end

        opts.on_tail("-v", "--version", "Print version number") do
          require "geocoder/version"
          out << "Geocoder #{Geocoder::VERSION}\n"
          exit
        end

        opts.on_tail("-h", "--help", "Print this help") do
          out << "Look up geographic information about a location.\n\n"
          out << opts
          out << "\nCreated and maintained by Alex Reisner, available under the MIT License.\n"
          out << "Report bugs and contribute at http://github.com/alexreisner/geocoder\n"
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
        lookup = Geocoder.send(:lookup, query)
        reverse = lookup.send(:coordinates?, query)
        out << lookup.send(:query_url, query, reverse) + "\n"
        exit 0
      end

      if show_json
        lookup = Geocoder.send(:lookup, query)
        reverse = lookup.send(:coordinates?, query)
        out << lookup.send(:fetch_raw_data, query, reverse) + "\n"
        exit 0
      end

      if (result = Geocoder.search(query).first)
        lookup = Geocoder.send(:get_lookup, :google)
        lines = [
          ["Latitude",       result.latitude],
          ["Longitude",      result.longitude],
          ["Full address",   result.address],
          ["City",           result.city],
          ["State/province", result.state],
          ["Postal code",    result.postal_code],
          ["Country",        result.country],
          ["Google map",     lookup.map_link_url(result.coordinates)],
        ]
        lines.each do |line|
          out << (line[0] + ": ").ljust(18) + line[1].to_s + "\n"
        end
        exit 0
      else
        out << "Location '#{query}' not found.\n"
        exit 1
      end
    end
  end
end
