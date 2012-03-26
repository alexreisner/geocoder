module Geocoder
  module Store
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
        [:latitude, :longitude].map do |i|
          if assoc = self.class.geocoder_options[:through]
            send assoc.name
          else
            self
          end.send self.class.geocoder_options[i]
        end
      end

      ##
      # Calculate the distance from the object to an arbitrary point.
      # See Geocoder::Calculations.distance_between for ways of specifying
      # the point. Also takes a symbol specifying the units
      # (:mi or :km; default is :mi).
      #
      def distance_to(point, units = :mi)
        return nil unless geocoded?
        Geocoder::Calculations.distance_between(
          to_coordinates, point, :units => units)
      end

      alias_method :distance_from, :distance_to

      ##
      # Calculate the bearing from the object to another point.
      # See Geocoder::Calculations.distance_between for
      # ways of specifying the point.
      #
      def bearing_to(point, options = {})
        return nil unless geocoded?
        Geocoder::Calculations.bearing_between(
          to_coordinates, point, options)
      end

      ##
      # Calculate the bearing from another point to the object.
      # See Geocoder::Calculations.distance_between for
      # ways of specifying the point.
      #
      def bearing_from(point, options = {})
        return nil unless geocoded?
        Geocoder::Calculations.bearing_between(
          point, to_coordinates, options)
      end

      ##
      # Get nearby geocoded objects.
      # Takes the same options hash as the near class method (scope).
      #
      def nearbys(radius = 20, options = {})
        return [] unless geocoded?
        options.merge!(:exclude => self)
        self.class.near(self, radius, options)
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

        target = options[:through] ? (send options[:through].name) : self

        if reverse and options[:reverse_geocode]
          query = to_coordinates
        elsif !reverse and options[:geocode]
          query = target.send(options[:user_address])
        else
          return
        end

        results = Geocoder.search(query)

        # execute custom block, if specified in configuration
        block_key = reverse ? :reverse_block : :geocode_block
        if custom_block = options[block_key]
          custom_block.call(target, results)

        # else execute block passed directly to this method,
        # which generally performs the "auto-assigns"
        elsif block_given?
          yield(target, results)
        end
      end
    end
  end
end
