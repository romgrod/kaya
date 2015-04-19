module Kaya
  module Custom
    class Params

      # This class is used to provide to user in his code access to the custom params sent
      # from Kaya

      def initialize
        params = ENV || {}
        @custom_params = if params["kaya_custom_params"]
         JSON.parse(params["kaya_custom_params"])
        else
          params
        end
      end

      def self.get
        self.new
      end

      def all_params
        @custom_params
      end

      def raw; all_params; end

      # All custom params can be called as methods
      def method_missing(param, *args, &block)
        @custom_params[param.to_s]
      end

    end
  end
end