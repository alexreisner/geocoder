module Geocoder
  module Orm
    module Base

      ##
      # Is this object geocoded? (Does it have latitude and longitude?)
      #
      def geocoded?
        to_coordinates.compact.size > 0
      end

      ##
      # Coordinates [lat,lon] of the object.
      #
      def to_coordinates
        [:latitude, :longitude].map{ |i| send self.class.geocoder_options[i] }
      end

      ##
      # Calculate the distance from the object to an arbitrary point.
      # Takes two floats (latitude, longitude) and a symbol specifying the
      # units to be used (:mi or :km; default is :mi).
      #
      def distance_to(lat, lon, units = :mi)
        return nil unless geocoded?
        mylat,mylon = to_coordinates
        Geocoder::Calculations.distance_between(mylat, mylon, lat, lon, :units => units)
      end

      alias_method :distance_from, :distance_to

      ##
      # Get nearby geocoded objects.
      # Takes the same options hash as the near class method (scope).
      #
      def nearbys(radius = 20, options = {})
        return [] unless geocoded?
        if options.is_a?(Symbol)
          options = {:units => options}
          warn "DEPRECATION WARNING: The units argument to the nearbys method has been replaced with an options hash (same options hash as the near scope). You should instead call: obj.nearbys(#{radius}, :units => #{options[:units]}). The old syntax will not be supported in Geocoder v1.0."
        end
        options.merge!(:exclude => self)
        self.class.near(to_coordinates, radius, options)
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
      # geocoded_by or reverse_geocoded_by) and handle the results with the
      # block (given to geocoded_by or reverse_geocoded_by). The block is
      # given two-arguments: the object being geocoded and an array of
      # Geocoder::Result objects).
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

        if (results = Geocoder.search(*args)).size > 0

          # execute custom block, if specified in configuration
          block_key = reverse ? :reverse_block : :geocode_block
          if custom_block = options[block_key]
            custom_block.call(self, results)

          # else execute block passed directly to this method,
          # which generally performs the "auto-assigns"
          elsif block_given?
            yield(self, results)
          end
        end
      end
    end
  end
end
