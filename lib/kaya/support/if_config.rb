module Kaya
  module Support
    module IfConfig
      def self.ip
        begin
          if_config_output = `ifconfig`
          if_config_output.scan(/:(\d+\.\d+\.\d+\.\d+)/).first.first
        rescue
          nil
        end
      end
    end
  end
end