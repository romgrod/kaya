module Kaya
  module Support
    class QueryString

      attr_reader :values, :req

      # req = Request
      def initialize req
        @req = req
        @values = Rack::Utils.parse_nested_query(req.query_string.split("/").last)
      end

      def raw
        return nil if @values.empty?
        @values.keys.first
      end

      def value_for key
        @values[key]
      end

      def method_missing(key, *args, &block)
        @values[key.to_s]
      end
    end
  end
end