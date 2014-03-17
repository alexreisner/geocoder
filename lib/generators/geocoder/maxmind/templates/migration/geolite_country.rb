class GeocoderMaxmindGeoliteCountry < ActiveRecord::Migration
  def self.up
    create_table :maxmind_geolite_country, id: false do |t|
      t.column :startIp, :string
      t.column :endIp, :string
      t.column :startIpNum, 'integer unsigned', null: false
      t.column :endIpNum, 'integer unsigned', null: false
      t.column :country_code, :string, null: false
      t.column :country, :string, null: false
    end
    add_index :maxmind_geolite_country, :startIpNum, unique: true
  end

  def self.down
    drop_table :maxmind_geolite_country
  end
end
