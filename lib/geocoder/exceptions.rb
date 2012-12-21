module Geocoder

  class Error < StandardError
  end

  class ConfigurationError < Error
  end

  class OverQueryLimitError < Error
  end

  class RequestDenied < Error
  end

  class InvalidRequest < Error
  end

  class InvalidApiKey < Error
  end

end
