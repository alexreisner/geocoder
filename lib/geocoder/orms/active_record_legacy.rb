module Geocoder::Orm::ActiveRecord
  module Legacy

    ##
    # Fetch coordinates and update (save) +latitude+ and +longitude+ data.
    #
    def fetch_coordinates!
      warn "DEPRECATION WARNING: The 'fetch_coordinates!' method is deprecated and will be removed in geocoder v1.0. " +
        "Please use 'geocode' instead and then save your objects manually."
      do_lookup(false) do |o,r|
        unless r.latitude.nil? or r.longitude.nil?
          o.send :update_attribute, self.class.geocoder_options[:latitude],  r.latitude
          o.send :update_attribute, self.class.geocoder_options[:longitude], r.longitude
        end
        r.coordinates
      end
    end

    def fetch_coordinates(*args)
      warn "DEPRECATION WARNING: The 'fetch_coordinates' method will cease taking " +
        "an argument in geocoder v1.0. Please save your objects manually." if args.size > 0
      do_lookup(false) do |o,r|
        unless r.latitude.nil? or r.longitude.nil?
          method = ((args.size > 0 && args.first) ? "update" : "write" ) + "_attribute"
          o.send method, self.class.geocoder_options[:latitude],  r.latitude
          o.send method, self.class.geocoder_options[:longitude], r.longitude
        end
        r.coordinates
      end
    end

    ##
    # Fetch address and update (save) +address+ data.
    #
    def fetch_address!
      warn "DEPRECATION WARNING: The 'fetch_address!' method is deprecated and will be removed in geocoder v1.0. " +
        "Please use 'reverse_geocode' instead and then save your objects manually."
      do_lookup(true) do |o,r|
        unless r.address.nil?
          o.send :update_attribute, self.class.geocoder_options[:fetched_address], r.address
        end
        r.address
      end
    end

    def fetch_address(*args)
      warn "DEPRECATION WARNING: The 'fetch_address' method will cease taking " +
        "an argument in geocoder v1.0. Please save your objects manually." if args.size > 0
      do_lookup(true) do |o,r|
        unless r.latitude.nil? or r.longitude.nil?
          method = ((args.size > 0 && args.first) ? "update" : "write" ) + "_attribute"
          o.send method, self.class.geocoder_options[:fetched_address], r.address
        end
        r.address
      end
    end
  end
end
