module Geocoder
  class Configuration

    def self.options_and_defaults
      [
        # geocoding service timeout (secs)
        [:timeout, 3],

        # name of geocoding service (symbol)
        [:lookup, :google],

        # ISO-639 language code
        [:language, :en],

        # :mi for miles or :km for kilometers
        [:units, :mi],

        # use HTTPS for lookup requests? (if supported)
        [:use_https, false],

        # HTTP proxy server (user:pass@host:port)
        [:http_proxy, nil],

        # HTTPS proxy server (user:pass@host:port)
        [:https_proxy, nil],

        # API key for geocoding service
        # for Google Premier use a 3-element array: [key, client, channel]
        [:api_key, nil],

        # cache object (must respond to #[], #[]=, and #keys)
        [:cache, nil],

        # prefix (string) to use for all cache keys
        [:cache_prefix, "geocoder:"],

        # exceptions that should not be rescued by default
        # (if you want to implement custom error handling);
        # supports SocketError and TimeoutError
        [:always_raise, []]
      ]
    end

    # define getters and setters for all configuration settings
    self.options_and_defaults.each do |option, default|
      class_eval(<<-END, __FILE__, __LINE__ + 1)

        @@#{option} = default unless defined? @@#{option}

        def self.#{option}
          @@#{option}
        end

        def self.#{option}=(obj)
          @@#{option} = obj
        end

      END
    end
  end
end
