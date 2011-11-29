module Geocoder

  class Error < StandardError
  end

  class ConfigurationError < Error
  end

  class OverQueryLimitError < Error
  end
end
