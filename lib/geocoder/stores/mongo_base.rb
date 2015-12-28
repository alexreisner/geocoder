module Geocoder::Store
  module MongoBase

    def self.included_by_model(base)
      base.class_eval do

        scope :geocoded, lambda {
          where(geocoder_options[:coordinates].ne => nil)
        }

        scope :not_geocoded, lambda {
          where(geocoder_options[:coordinates] => nil)
        }

        scope :near, lambda{ |location, *args|
          warn "DEPRECATION WARNING: The .near method will be removed for MongoDB-backed models in Geocoder 1.3.0. Please use MongoDB's built-in query language instead."
          coords  = Geocoder::Calculations.extract_coordinates(location)

          # no results if no lat/lon given
          return where(:id => false) unless coords.is_a?(Array)

          radius  = args.size > 0 ? args.shift : 20
          options = args.size > 0 ? args.shift : {}
          options[:units] ||= geocoder_options[:units]

          # Use BSON::OrderedHash if Ruby's hashes are unordered.
          # Conditions must be in order required by indexes (see mongo gem).
          version = RUBY_VERSION.split('.').map { |i| i.to_i }
          empty = version[0] < 2 && version[1] < 9 ? BSON::OrderedHash.new : {}

          conds = empty.clone
          field = geocoder_options[:coordinates]
          conds[field] = empty.clone
          conds[field]["$nearSphere"]  = coords.reverse

          if radius
            conds[field]["$maxDistance"] = \
              Geocoder::Calculations.distance_to_radians(radius, options[:units])
          end

          if obj = options[:exclude]
            conds[:_id.ne] = obj.id
          end
          where(conds)
        }
      end
    end

    ##
    # Coordinates [lat,lon] of the object.
    # This method always returns coordinates in lat,lon order,
    # even though internally they are stored in the opposite order.
    #
    def to_coordinates
      coords = send(self.class.geocoder_options[:coordinates])
      coords.is_a?(Array) ? coords.reverse : []
    end

    ##
    # Get nearby geocoded objects.
    # Takes the same options hash as the near class method (scope).
    # Returns nil if the object is not geocoded.
    #
    def nearbys(radius = 20, options = {})
      warn "DEPRECATION WARNING: The #nearbys method will be removed for MongoDB-backed models in Geocoder 1.3.0. Please use MongoDB's built-in query language instead."
      return nil unless geocoded?
      options.merge!(:exclude => self) unless send(self.class.primary_key).nil?
      self.class.near(self, radius, options)
    end

    ##
    # Look up coordinates and assign to +latitude+ and +longitude+ attributes
    # (or other as specified in +geocoded_by+). Returns coordinates (array).
    #
    def geocode
      do_lookup(false) do |o,rs|
        if r = rs.first
          unless r.coordinates.nil?
            o.__send__ "#{self.class.geocoder_options[:coordinates]}=", r.coordinates.reverse
          end
          r.coordinates
        end
      end
    end

    ##
    # Look up address and assign to +address+ attribute (or other as specified
    # in +reverse_geocoded_by+). Returns address (string).
    #
    def reverse_geocode
      do_lookup(true) do |o,rs|
        if r = rs.first
          unless r.address.nil?
            o.__send__ "#{self.class.geocoder_options[:fetched_address]}=", r.address
          end
          r.address
        end
      end
    end
  end
end

