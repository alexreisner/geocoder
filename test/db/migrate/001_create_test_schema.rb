# CreateTestSchema creates the tables used in test_helper.rb

superclass = ActiveRecord::Migration
# TODO: Inherit from the 5.0 Migration class directly when we drop support for Rails 4.
superclass = ActiveRecord::Migration[5.0] if superclass.respond_to?(:[])

class CreateTestSchema < superclass
  def self.up
    [
      :places,
      :place_reverse_geocodeds
    ].each do |table|
      create_table table do |t|
        t.column :name, :string
        t.column :address, :string
        t.column :latitude, :decimal, :precision => 16, :scale => 6
        t.column :longitude, :decimal, :precision => 16, :scale => 6
        t.column :radius_column, :decimal, :precision => 16, :scale => 6
      end
    end

    [
      :place_with_custom_lookup_procs,
      :place_with_custom_lookups,
      :place_reverse_geocoded_with_custom_lookups
    ].each do |table|
      create_table table do |t|
        t.column :name, :string
        t.column :address, :string
        t.column :latitude, :decimal, :precision => 16, :scale => 6
        t.column :longitude, :decimal, :precision => 16, :scale => 6
        t.column :result_class, :string
      end
    end

    create_table :place_with_forward_and_reverse_geocodings do |t|
      t.column :name, :string
      t.column :location, :string
      t.column :lat, :decimal, :precision => 16, :scale => 6
      t.column :lon, :decimal, :precision => 16, :scale => 6
      t.column :address, :string
    end

    create_table :place_reverse_geocoded_with_custom_results_handlings do |t|
      t.column :name, :string
      t.column :address, :string
      t.column :latitude, :decimal, :precision => 16, :scale => 6
      t.column :longitude, :decimal, :precision => 16, :scale => 6
      t.column :country, :string
    end

    create_table :place_with_custom_results_handlings do |t|
      t.column :name, :string
      t.column :address, :string
      t.column :latitude, :decimal, :precision => 16, :scale => 6
      t.column :longitude, :decimal, :precision => 16, :scale => 6
      t.column :coords_string, :string
    end
  end
end
