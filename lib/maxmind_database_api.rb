require 'maxmind_database'

# Maxmind API changed, so no open downloads are available anymore. Only API-protected calls are allowed.
module Geocoder
  module MaxmindDatabaseApi
    extend ::Geocoder::MaxmindDatabase

    class << self
      def download(package, dir = "tmp")
        filepath = File.expand_path(File.join(dir, archive_filename(package)))
        open(filepath, 'wb') do |file|
          uri = URI.parse(archive_url(package))
          Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http| # enabled use of ssl
            http.request_get("#{uri.path}?#{uri.query}") do |resp| # added query parameters
              puts 'downloading'
              pkg_num = 0

              resp.read_body do |segment|
                pkg_num += 1
                print '.' if pkg_num % 500 == 0

                file.write(segment)
              end

              puts 'done.'
            end
          end
        end
      end

      def archive_url_path(package)
        {
          # geolite_country_csv: "GeoLite2-Country-CSV", # currently not supported
          geolite_city_csv: 'GeoLite2-City-CSV'
          # geolite_asn_csv: "GeoLite2-ASN-CSV" # currently not supported
        }[package]
      end

      def base_url
        download_api_key = Geocoder.config[:maxmind_local_api].try(:[], :download_api_key)
        raise '*maxmind_local_api -> download_api_key* is a mandatory configuration option' unless download_api_key

        "https://download.maxmind.com/app/geoip_download?license_key=#{download_api_key}&suffix=zip&edition_id="
      end

      def data_files(package, dir = 'tmp')
        case package
        when :geolite_city_csv
          # use the last two in case multiple versions exist
          city_files = Dir.glob(File.join(dir, "GeoLite2-City-CSV*/*-#{Geocoder.config[:maxmind_local_api].try(:[], :preferred_language) || 'en'}.csv"))
          city_files = Dir.glob(File.join(dir, 'GeoLite2-City-CSV*/*-en.csv')) if city_files.empty? # fallback to english if preferred language isnt included in archive

          city_block_files = Dir.glob(File.join(dir, 'GeoLite2-City-CSV*/*Blocks*.csv'))
          city_block_files.delete_if { |f| f =~ /IPv6/ } # skip IPv6 for now, as other datatypes or table will be necessary to improve performance

          db_tables = ['maxmind_geolite_city_blocks', 'maxmind_geolite_city_location']

          {
            'maxmind_geolite_city_location' => city_files,
            'maxmind_geolite_city_blocks' => city_block_files
          }

        when :geolite_country_csv
          raise 'Currently update is not implemented. Use city instead.'
          # {File.join(dir, "GeoIPCountryWhois.csv") => "maxmind_geolite_country"}
        end
      end

      def insert(package, dir = 'tmp')
        resetted_tables = []

        data_files(package, dir).each do |table, filepaths|
          puts "Resetting table #{table}..."
          ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table}")

          puts "Loading data for table #{table}"

          filepaths.each do |filepath|
            puts "Inserting from file #{filepath}"
            insert_into_table(table, filepath)
          end

          puts 'Optimizing table'
          ActiveRecord::Base.connection.execute("OPTIMIZE TABLE #{table}")
        end
      end

      def insert_into_table(table, filepath)
        start_time = Time.now

        rows = []
        header_columns = nil

        CSV.foreach(filepath, encoding: 'utf-8') do |line| # now UTF-8!
          # Each file's first record is a header; ignore it
          unless header_columns
            header_columns = line.to_a
            next
          end

          rows << line.to_a
          if rows.size == 10000
            insert_rows(table, header_columns, rows)
            rows = []
            print '.'
          end
        end

        insert_rows(table, header_columns, rows) if rows.size > 0

        puts "\ndone (#{Time.now - start_time} seconds)"
      end


      def insert_rows(table, headers, rows)
        network_col_idx = headers.index('network')
        header_columns = network_col_idx ? adjust_header_columns(headers) : headers

        # adjust data from network to from-/to bigints
        if network_col_idx
          rows.each do |row|
            addr_range = IPAddr.new(row[network_col_idx]).to_range
            row[network_col_idx, 1] = [addr_range.first.to_i, addr_range.last.to_i]
          end
        end

        # go on with defaults
        super(table, header_columns, rows)
      end


      def adjust_header_columns(header_columns)
        if idx = header_columns.index('network')
          new_header_columns = header_columns.dup
          new_header_columns[idx, 1] = %w(start_ip_num end_ip_num)
          new_header_columns
        else
          header_columns
        end
      end
    end
  end
end
