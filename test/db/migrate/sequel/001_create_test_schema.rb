#  creates the tables used in test_sequel_helper.rb

Sequel.migration do
  up do
    create_table :places do
      primary_key :id
      String :name
      String :address
      Decimal :latitude, :precision => 16, :scale => 6
      Decimal :longitude, :precision => 16, :scale => 6
      Decimal :radius_column, :precision => 16, :scale => 6
    end

    create_table :places_with_result_class do
      primary_key :id
      String :name
      String :address
      Decimal :latitude, :precision => 16, :scale => 6
      Decimal :longitude, :precision => 16, :scale => 6
      String :result_class
    end

    create_table :place_with_forward_and_reverse_geocodings do
      String :name
      String :location
      Decimal :lat, :precision => 16, :scale => 6
      Decimal :lon, :precision => 16, :scale => 6
      String :address
    end

    create_table :place_reverse_geocoded_with_custom_results_handlings do
      String :name
      String :address
      Decimal :latitude, :precision => 16, :scale => 6
      Decimal :longitude, :precision => 16, :scale => 6
      String :country
    end

    create_table :place_with_custom_results_handlings do
      String :name
      String :address
      Decimal :latitude, :precision => 16, :scale => 6
      Decimal :longitude, :precision => 16, :scale => 6
      String :coords_string
    end
  end

  down do
    drop_tables(:places, :places_with_result_class, :place_with_forward_and_reverse_geocodings, :place_reverse_geocoded_with_custom_results_handlings, :place_with_custom_results_handlings)
  end
end
