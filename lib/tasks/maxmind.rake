namespace :geocoder do
  namespace :maxmind do
    namespace :geolite_city do

      desc "Load MaxMind GeoLite City into SQL database"
      task load_data: :environment do
        clear_tables_mysql
        load_table_mysql('maxmind_blocks', 'tmp/GeoLiteCity-Blocks.csv')
        load_table_mysql('maxmind_location', 'tmp/GeoLiteCity-Location.csv')
      end
    end
  end
end

# IMPORTANT: http://stackoverflow.com/questions/10737974/load-data-local-infile-gives-the-error-the-used-command-is-not-allowed-with-this
def load_table_mysql(table, filepath)
  q = <<-END
    LOAD DATA LOCAL INFILE '#{filepath}'
    INTO TABLE #{table}
    IGNORE 2 LINES
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '\"'
    LINES TERMINATED BY '\n';
  END
  ActiveRecord::Base.connection.execute(q)
end

def clear_tables_mysql
  [
    #"LOCK TABLES maxmind_blocks READ, maxmind_location READ",
    "DELETE from maxmind_blocks",
    "DELETE from maxmind_location",
    #"UNLOCK TABLES"
  ].each{ |q| ActiveRecord::Base.connection.execute(q) }
end
