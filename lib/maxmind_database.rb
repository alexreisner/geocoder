require 'csv'
require 'net/http'

module Geocoder
  module MaxmindDatabase
    extend self

    def download(package, dir = "tmp")
      filepath = File.expand_path(File.join(dir, archive_filename(package)))
      open(filepath, 'wb') do |file|
        uri = URI.parse(archive_url(package))
        Net::HTTP.start(uri.host, uri.port) do |http|
          http.request_get(uri.path) do |resp|
            # TODO: show progress
            resp.read_body do |segment|
              file.write(segment)
            end
          end
        end
      end
    end

    def insert(package, dir = "tmp")
      data_files(package).each do |filepath,table|
        # delete from table
        print "Resetting table #{table}..."
        ActiveRecord::Base.connection.execute("DELETE FROM #{table}")
        puts "done"
        # insert into table
        start_time = Time.now
        print "Loading data for table #{table}"
        rows = []
        headers = nil
        CSV.foreach(filepath, encoding: "ISO-8859-1") do |line|
          if line.first[0...9] == "Copyright"
            next
          elsif headers.nil?
            headers = line
            next
          else
            rows << line.to_a
            if rows.size == 10000
              insert_into_table(table, headers, rows)
              rows = []
              print "."
            end
          end
        end
        insert_into_table(table, headers, rows) if rows.size > 0
        puts "done (#{Time.now - start_time} seconds)"
      end
    end

    def archive_filename(package)
      p = archive_url_path(package)
      s = !(pos = p.rindex('/')).nil? && pos + 1 || 0
      p[s..-1]
    end

    private # -------------------------------------------------------------

    def insert_into_table(table, headers, rows)
      value_strings = rows.map do |row|
        "(" + row.map{ |col| sql_escaped_value(col) }.join(',') + ")"
      end
      q = "INSERT INTO #{table} (#{headers.join(',')}) " +
        "VALUES #{value_strings.join(',')}"
      ActiveRecord::Base.connection.execute(q)
    end

    def sql_escaped_value(value)
      value.to_i.to_s == value ? value :
        ActiveRecord::Base.connection.quote(value)
    end

    def data_files(package, dir = "tmp")
      case package
      when :geolite_city_csv
        # use the last two in case multiple versions exist
        files = Dir.glob(File.join(dir, "GeoLiteCity_*/*.csv"))[-2..-1]
        Hash[*files.zip(["maxmind_geolite_city_blocks", "maxmind_geolite_city_location"]).flatten]
      end
    end

    def archive_url(package)
      base_url + archive_url_path(package)
    end

    def archive_url_path(package)
      {
        geolite_country_csv: "GeoIPCountryCSV.zip",
        geolite_city_csv: "GeoLiteCity_CSV/GeoLiteCity-latest.zip",
        geolite_asn_csv: "asnum/GeoIPASNum2.zip"
      }[package]
    end

    def base_url
      "http://geolite.maxmind.com/download/geoip/database/"
    end
  end
end
