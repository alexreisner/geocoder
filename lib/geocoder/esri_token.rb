module Geocoder::Token
  class EsriToken
    attr_accessor :value, :expires_at

    def initialize(value, expires_at)
      @value = value
      @expires_at = expires_at
    end

    def to_s
        @value
    end

    def valid?
      @expires_at > Time.now
    end
  end
end
