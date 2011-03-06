module Geocoder
  module Orm
    module Base

      ##
      # Is this object geocoded? (Does it have latitude and longitude?)
      #
      def geocoded?
        read_coordinates.compact.size > 0
      end

      ##
      # Calculate the distance from the object to an arbitrary point.
      # Takes two floats (latitude, longitude) and a symbol specifying the
      # units to be used (:mi or :km; default is :mi).
      #
      def distance_to(lat, lon, units = :mi)
        return nil unless geocoded?
        mylat,mylon = read_coordinates
        Geocoder::Calculations.distance_between(mylat, mylon, lat, lon, :units => units)
      end

      alias_method :distance_from, :distance_to

      ##
      # Get nearby geocoded objects. Takes a radius (integer) and a symbol
      # representing the units of the ratius (:mi or :km; default is :mi).
      #
      def nearbys(radius = 20, units = :mi)
        return [] unless geocoded?
        options = {:exclude => self, :units => units}
        self.class.near(read_coordinates, radius, options)
      end

      ##
      # Look up geographic data based on object attributes (configured in
      # geocoded_by or reverse_geocoded_by) and handle the result with the
      # block (given to geocoded_by or reverse_geocoded_by). The block is
      # given two-arguments: the object being geocoded and a
      # Geocoder::Result object with the geocoding results).
      #
      def geocode
        options = self.class.geocoder_options
        args = options[:user_address] ?
          [:user_address] : [:latitude, :longitude]
        args.map!{ |a| send(options[a]) }

        # passing a block to this method overrides the one given in the model
        if result = Geocoder.search(*args)
          if block_given?
            yield(self, result)
          else
            self.class.geocoder_options[:block].call(self, result)
          end
        end
      end


      private # --------------------------------------------------------------

      ##
      # Read the coordinates [lat,lon] of the object.
      # Looks at user config to determine attributes.
      #
      def read_coordinates
        [:latitude, :longitude].map{ |i| send self.class.geocoder_options[i] }
      end
    end
  end
end
