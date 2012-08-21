Geocoder.configure do |config|
  ## Configurable parameters: if you wish to change some configurable
  ## behaviour in Geocoder, feel free to uncomment the following lines
  ## and provide custom parameters.

  # config.timeout      = 3           # geocoding service timeout (secs)
  # config.lookup       = :google     # name of geocoding service (symbol)
  # config.language     = :en         # ISO-639 language code
  # config.use_https    = false       # use HTTPS for lookup requests? (if supported)
  # config.http_proxy   = nil         # HTTP proxy server (user:pass@host:port)
  # config.https_proxy  = nil         # HTTPS proxy server (user:pass@host:port)
  # config.api_key      = nil         # API key for geocoding service
  # config.cache        = nil         # cache object (must respond to #[], #[]=, and #keys)
  # config.cache_prefix = "geocoder:" # prefix (string) to use for all cache keys

  ## exceptions that should not be rescued by default
  ## (if you want to implement custom error handling);
  ## supports SocketError and TimeoutError
  # config.always_raise = []

  ## Calculation options
  # config.units     = :mi        # :km for kilometers or :mi for miles
  # config.distances = :linear    # :spherical or :linear
end

