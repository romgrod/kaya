module Kaya
  module Support
    class TimeHelper

      def self.formatted_time_for timestamp
        Time.at(timestamp).strftime(Kaya::Support::Configuration.formatted_datetime)
      end

    end
  end
end