require 'geocoder/lookups/base'
require 'geocoder/results/dummy'

module Geocoder::Lookup
  class Dummy < Base
    class << self
      def queries
        @queries || {}
      end

      def add_query query, *datas
        @queries ||= {}
        @queries[query.to_str] = datas.flatten.map do |data|
          Geocoder::Result::Dummy.new(data)
        end
      end

      def remove_query query
        @queries.delete(query.to_str) if @queries
      end

      def clear_queries
        # don't do anything unless we have queries
        return unless @queries
        @queries.clear
      end
    end

    def search(query)
      results = self.class.queries[query.to_str]
      if results
        results
      else
        warn "No results were found for '#{query}'"
        return []
      end
    end
  end
end
