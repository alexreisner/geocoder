require 'singleton'
require 'geocoder/configuration_hash'

module Geocoder

  ##
  # Configuration options should be set by passing a hash:
  #
  #   Geocoder.configure(
  #     :timeout  => 5,
  #     :lookup   => :yandex,
  #     :api_key  => "2a9fsa983jaslfj982fjasd",
  #     :units    => :km
  #   )
  #
  def self.configure(options = nil, &block)
    if !options.nil?
      Configuration.instance.configure(options)
    end
  end

  ##
  # Read-only access to the singleton's config data.
  #
  def self.config
    Configuration.instance.data
  end

  ##
  # Read-only access to lookup-specific config data.
  #
  def self.config_for_lookup(lookup_name)
    data = config.clone
    data.reject!{ |key,value| !Configuration::OPTIONS.include?(key) }
    if config.has_key?(lookup_name)
      data.merge!(config[lookup_name])
    end
    data
  end

  ##
  # Merge the given hash into a lookup's existing configuration.
  #
  def self.merge_into_lookup_config(lookup_name, options)
    base = Geocoder.config[lookup_name]
    Geocoder.configure(lookup_name => base.merge(options))
  end

  class Configuration
    include Singleton

    OPTIONS = [
      :timeout,
      :lookup,
      :ip_lookup,
      :language,
      :http_headers,
      :use_https,
      :http_proxy,
      :https_proxy,
      :api_key,
      :cache,
      :cache_prefix,
      :cache_compress,
      :always_raise,
      :units,
      :distances,
      :basic_auth,
      :logger,
      :kernel_logger_level
    ]

    attr_accessor :data

    def self.set_defaults
      instance.set_defaults
    end

    OPTIONS.each do |o|
      define_method o do
        @data[o]
      end
      define_method "#{o}=" do |value|
        @data[o] = value
      end
    end

    def configure(options)
      @data.rmerge!(options)
    end

    def initialize # :nodoc
      @data = Geocoder::ConfigurationHash.new
      set_defaults
    end

    def set_defaults

      # geocoding options

      # geocoding service timeout (secs)
      @data[:timeout] = 3
      # name of street address geocoding service (symbol)
      @data[:lookup] = :google
      # name of IP address geocoding service (symbol)
      @data[:ip_lookup] = :freegeoip
      # ISO-639 language code
      @data[:language] = :en
      # HTTP headers for lookup
      @data[:http_headers] = {}
      # use HTTPS for lookup requests? (if supported)
      @data[:use_https] = false
      # HTTP proxy server (user:pass@host:port)
      @data[:http_proxy] = nil
      # HTTPS proxy server (user:pass@host:port)
      @data[:https_proxy] = nil
      # API key for geocoding service
      @data[:api_key] = nil
      # cache object (must respond to #[], #[]=, and #keys)
      @data[:cache] = nil
      # prefix (string) to use for all cache keys
      @data[:cache_prefix] = "geocoder:"
      # compress cache values larger than 1KB
      @data[:cache_compress] = false
      # user and password for basic auth ({:user => "user", :password => "password"})
      @data[:basic_auth] = {}
      # :kernel or Logger instance
      @data[:logger] = :kernel
      # log level, if kernel logger is used
      @data[:kernel_logger_level] = ::Logger::WARN

      # exceptions that should not be rescued by default
      # (if you want to implement custom error handling);
      # supports SocketError and Timeout::Error
      @data[:always_raise] = []

      # calculation options
      @data[:units]     = :mi      # :mi or :km
      @data[:distances] = :linear  # :linear or :spherical
    end

    instance_eval(OPTIONS.map do |option|
      o = option.to_s
      <<-EOS
      def #{o}
        instance.data[:#{o}]
      end

      def #{o}=(value)
        instance.data[:#{o}] = value
      end
      EOS
    end.join("\n\n"))
  end
end
