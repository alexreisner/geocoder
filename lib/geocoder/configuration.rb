require 'singleton'

module Geocoder

  ##
  # Provides convenient access to the Configuration singleton.
  #
  def self.configure(&block)
    if block_given?
      block.call(Configuration.instance)
    else
      Configuration.instance
    end
  end

  ##
  # Provides an easy way to access to a parametrized configuration
  #
  class ConfigHash
    attr_reader :options
    def initialize(hash, options = {})
      @hash = hash
      @options = options
    end

    def method_missing(method, *args)
      unless args.empty?
        config_hash = {}
        config_hash[method[0...-1].to_sym] = args.first
        Geocoder.configure.configure_lookup(options[:lookup], config_hash)
      end

      @hash[method.to_sym]
    end
  end

  ##
  # This class handles geocoder Geocoder configuration
  # (geocoding service provider, caching, units of measurement, etc).
  # Configuration can be done in two ways:
  #
  # 1) Using Geocoder.configure and passing a block
  #    (useful for configuring multiple things at once):
  #
  #   Geocoder.configure do |config|
  #     config.timeout      = 5
  #     config.lookup       = :yandex
  #     config.api_key      = "2a9fsa983jaslfj982fjasd"
  #     config.units        = :km
  #   end
  #
  # 2) Using the Geocoder::Configuration singleton directly:
  #
  #   Geocoder::Configuration.language = 'pt-BR'
  #
  # Default values are defined in Configuration#set_defaults.
  #
  class Configuration
    include Singleton

    DEFAULT_LOOKUP_KEY = :default

    BASE_OPTIONS = [
      :lookup,
      :ip_lookup,
    ]

    OPTIONS = [
      :timeout,
      :language,
      :http_headers,
      :use_https,
      :http_proxy,
      :https_proxy,
      :api_key,
      :cache,
      :cache_prefix,
      :always_raise,
      :units,
      :distances
    ]


    ##
    # Method to define virtual getter/setter which access to configuration
    #
    def self.attr_accessor_using_lookup_option(*args)
      args.each do |arg|
        # define getter
        self.class_eval(%Q?
          def #{arg}
            get_lookup_option(DEFAULT_LOOKUP_KEY, "#{arg}".to_sym)
          end
        ?)
        
        # define setter
        self.class_eval(%Q?
          def #{arg}=(val)
            configure_lookup(DEFAULT_LOOKUP_KEY, :#{arg} => val)
          end
        ?)
      end
    end

    ##
    # Hash operator used to simplify configuration.
    # example : 
    # Geocoder.configure[:default].timeout = 5
    # => returns 5
    # Geocoder.configure[:google].timeout = 3
    # => returns 3
    # Geocoder.configure[:geocoder_ca].timeout
    # => returns 5 (default configuration used)
    #
    def [](lookup)
      config = configure_lookup(DEFAULT_LOOKUP_KEY).merge(configure_lookup(lookup))
      ConfigHash.new(config, :lookup => lookup)
    end

    # defining attributes and virtual attributes
    attr_accessor *BASE_OPTIONS
    attr_accessor_using_lookup_option *OPTIONS

    def initialize # :nodoc
      @lookup_config = {}
      set_defaults
    end

    def set_defaults
      # base options
      self.lookup       = :google     # name of street address geocoding service (symbol)
      self.ip_lookup    = :freegeoip  # name of IP address geocoding service (symbol)

      # (other) options
      self.timeout      = 3           # geocoding service timeout (secs)
      self.language     = :en         # ISO-639 language code
      self.http_headers = {}          # HTTP headers for lookup
      self.use_https    = false       # use HTTPS for lookup requests? (if supported)
      self.http_proxy   = nil         # HTTP proxy server (user:pass@host:port)
      self.https_proxy  = nil         # HTTPS proxy server (user:pass@host:port)
      self.api_key      = nil         # API key for geocoding service
      self.cache        = nil         # cache object (must respond to #[], #[]=, and #keys)
      self.cache_prefix = "geocoder:" # prefix (string) to use for all cache keys

      # exceptions that should not be rescued by default
      # (if you want to implement custom error handling);
      # supports SocketError and TimeoutError
      self.always_raise = []

      # calculation options
      self.units     = :mi     # :mi or :km
      self.distances = :linear # :linear or :spherical

    end

    ##
    # Configure specified lookup with provided options
    #
    def configure_lookup(lookup, options = {})
      @lookup_config[lookup] ||= {}
      @lookup_config[lookup].merge! options unless options.empty?
      @lookup_config[lookup]
    end

    ##
    # Get option from lookup configuration
    #
    def get_lookup_option(lookup, option)
      config = configure_lookup(lookup)
      config[option] unless option.nil? || !config.include?(option)
    end

    instance_eval((BASE_OPTIONS + OPTIONS).map do |option|
      o = option.to_s
      <<-EOS
      def [](lookup)
        instance[lookup]
      end

      def #{o}
        instance.#{o}
      end

      def #{o}=(value)
        instance.#{o} = value
      end
      EOS
    end.join("\n\n"))

    class << self
      def set_defaults
        instance.set_defaults
      end
    end

  end
end
