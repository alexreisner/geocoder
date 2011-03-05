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
      def geocode
        options = self.class.geocoder_options
        args = options[:user_address] ?
          [:user_address] : [:latitude, :longitude]
        args.map!{ |a| send(options[a]) }

        # passing a block to this method overrides the one given in the model
        if result = Geocoder.search(*args).first
          if block_given?
            yield(result)
          else
            self.class.geocoder_options[:block].call(result)
          end
        end
      end
    end
  end
end
