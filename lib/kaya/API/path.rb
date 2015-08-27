module Kaya
  module API
    class Path

      def self.data data, query_string
          query_string.split(".").each do |key|
            key = key.to_i if key =~ /^\d+$/
            data = data[key]
          end
          data
      end
    end
  end
end