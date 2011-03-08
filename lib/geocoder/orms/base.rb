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
      # Look up coordinates and assign to +latitude+ and +longitude+ attributes
      # (or other as specified in +geocoded_by+). Returns coordinates (array).
      #
      def geocode
        fail
      end

      ##
      # Look up address and assign to +address+ attribute (or other as specified
      # in +reverse_geocoded_by+). Returns address (string).
      #
      def reverse_geocode
        fail
      end


      private # --------------------------------------------------------------

      ##
      # Look up geographic data based on object attributes (configured in
      # geocoded_by or reverse_geocoded_by) and handle the result with the
      # block (given to geocoded_by or reverse_geocoded_by). The block is
      # given two-arguments: the object being geocoded and a
      # Geocoder::Result object with the geocoding results).
      #
      def do_lookup(reverse = false)
        options = self.class.geocoder_options
        if reverse and options[:reverse_geocode]
          args = [:latitude, :longitude]
        elsif !reverse and options[:geocode]
          args = [:user_address]
        else
          return
        end
        args.map!{ |a| send(options[a]) }

        if result = Geocoder.search(*args)

          # execute custom block, if specified in configuration
          block_key = reverse ? :reverse_block : :geocode_block
          if custom_block = options[block_key]
            custom_block.call(self, result)

          # else execute block passed directly to this method,
          # which generally performs the "auto-assigns"
          elsif block_given?
            yield(self, result)
          end
        end
      end

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
