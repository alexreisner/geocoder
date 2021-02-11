class GeocoderMaxmindGeoliteCity < ActiveRecord::Migration<%= migration_version %>
  def change
    create_table :maxmind_geolite_city_blocks, id: false, force: true do |t|
      t.binary :start_ip_num, limit: 16, scale: 0, null: false, index: true, unique: true
      t.binary :end_ip_num, limit: 16, scale: 0, null: false
      t.bigint :geoname_id, index: true
      t.bigint :registered_country_geoname_id
      t.bigint :represented_country_geoname_id
      t.boolean :is_anonymous_proxy
      t.boolean :is_satellite_provider
      t.string :postal_code, limit: 32
      t.float :latitude
      t.float :longitude
      t.integer :accuracy_radius
    end

    add_index :maxmind_geolite_city_blocks, [:end_ip_num, :start_ip_num], unique: true, name: :index_maxmind_geolite_city_blocks_on_end_ip_num_range

    create_table :maxmind_geolite_city_location, id: false, force: true do |t|
      t.bigint :geoname_id, null: false
      t.string :locale_code, limit: 8 # language of translation (de, en, ...)
      t.string :continent_code, limit: 8 # EU, AF, AS, ...
      t.string :continent_name, limit: 64 # Continent in the *locale_code*s language (Europa, Afrika, ...)
      t.string :country_iso_code, limit: 8 # country code ISO: DE, BE, ...
      t.string :country_name, limit: 64 # Country in the *locale_code*s language  (Deutschland, Belgien, ...)
      t.string :subdivision_1_iso_code, limit: 8 # ISO Code Country division: 1 (BY, HE, BW, ...)
      t.string :subdivision_1_name, limit: 64 # Country division 1 in the *locale_code*s language (Bayern, Hessen, Baden-Württemberg, ...)
      t.string :subdivision_2_iso_code, limit: 8 # ISO Code Country division: 2
      t.string :subdivision_2_name, limit: 64 # Country division 2 in the *locale_code*s language
      t.string :city_name, limit: 64  # City name in *locale_code*s language
      t.string :metro_code, limit: 32 # Metro code only us
      t.string :time_zone, limit: 32 # Timezone (Europe/Berlin)
      t.boolean :is_in_european_union, null: false # in EU: true/false
    end

    add_index :maxmind_geolite_city_location, [:geoname_id, :locale_code], unique: true, name: :index_maxmind_geolite_city_blocks_pk
  end
end
