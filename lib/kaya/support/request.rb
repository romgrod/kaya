module Kaya
  module Support
    class Request

      def initialize req
        @req = req
      end

      def path
        self.path_info
      end

      def path_info
        @req.env["PATH_INFO"]
      end

      def ip
        @req.env["REMOTE_ADDR"]
      end

      def request
        @req.env
      end

      def method_missing(method_name, *args, &block)
        begin
          send("@req.#{method_name}", *args)
        rescue
          $K_LOG.error "#{method_name} not found for req in #{self.class}. Returning nil"
          nil
        end
      end

    end
  end
end