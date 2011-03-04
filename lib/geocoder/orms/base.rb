module Geocoder
  module Orm
    module Base

      ##
      # Read the coordinates [lat,lon] of an object. This is not great but it
      # seems cleaner than polluting the instance method namespace.
      #
      def read_coordinates
        [:latitude, :longitude].map{ |i| send self.class.geocoder_options[i] }
      end

      ##
      # Is this object geocoded? (Does it have latitude and longitude?)
      #
      def geocoded?
        read_coordinates.compact.size > 0
      end

      ##
      # Calculate the distance from the object to a point (lat,lon).
      #
      # <tt>:units</tt> :: <tt>:mi</tt> (default) or <tt>:km</tt>
      #
      def distance_to(lat, lon, units = :mi)
        return nil unless geocoded?
        mylat,mylon = read_coordinates
        Geocoder::Calculations.distance_between(mylat, mylon, lat, lon, :units => units)
      end

      ##
      # Get other geocoded objects within a given radius.
      #
      # <tt>:units</tt> :: <tt>:mi</tt> (default) or <tt>:km</tt>
      #
      def nearbys(radius = 20, units = :mi)
        return [] unless geocoded?
        options = {:exclude => self, :units => units}
        self.class.near(read_coordinates, radius, options)
      end

      ##
      # Look up geographic data based on object attributes,
      # and do something with it (requires a block).
      #
      def geocode(reverse = false, &block)
        if reverse
          lat_attr = self.class.geocoder_options[:latitude]
          lon_attr = self.class.geocoder_options[:longitude]
          unless lat_attr.is_a?(Symbol) and lon_attr.is_a?(Symbol)
            raise Geocoder::ConfigurationError,
              "You are attempting to fetch an address but have not specified " +
              "attributes which provide coordinates for the object."
          end
          args = [send(lat_attr), send(lon_attr)]
        else
          address_method = self.class.geocoder_options[:user_address]
          unless address_method.is_a? Symbol
            raise Geocoder::ConfigurationError,
              "You are attempting to geocode an object but have not specified " +
              "a method which provides an address to search for."
          end
          args = [send(address_method)]
        end
        # passing a block to this method overrides the one given in the model
        b = block_given?? block : self.class.geocoder_options[:block]
        if result = Geocoder.search(*args).first
          b.call(result)
        end
      end
    end
  end
end
