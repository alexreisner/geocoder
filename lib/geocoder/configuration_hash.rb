require 'hash_recursive_merge'

module Geocoder
  class ConfigurationHash < Hash
    include HashRecursiveMerge

    def method_missing(meth, *args, &block)
      has_key?(meth) ? self[meth] : super
    end
  end
end
