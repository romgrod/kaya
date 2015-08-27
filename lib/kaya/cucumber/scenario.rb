module Kaya
  module Cucumber
    class Scenario

      # Returns execution id
      def self.id
        ENV["_id"]
      end

      def self.is_there_result?
        Kaya::Database::MongoConnector.result_data_for_id(self.id)
      end

      #
      #
      #   This is only on Cucumber execution
      # Used on Before hooks as follow
      #    Before do |scenario|
      #      Kaya::Cucumber::Scenario.send_to_kaya(scenario)
      #      # your code
      #    end
      #
      # @param [Cucumber::RunningTestCase::Scenario]
      # @return [Boolean] true if added. Added means that result id exists and operation could be performed
      def self.send_to_kaya scenario
        # =>  [:duration, :duration=, :describe_to, :to_s, :passed?, :failed?, :undefined?, :unknown?, :skipped?, :pending?....]
        self.ensure_db_connection
        if self.is_there_result?
          result = self.get_result
          if result and result.running?
            details = {
              "name" => scenario.name,
              "status" => self.get_status(scenario),
              "location" => "#{scenario.location.file}:#{scenario.location.line}"
              }
            result.add_test_result details
          else
            false
          end
        end
      end

      def self.get_status scenario
        result = scenario.instance_variable_get(:@result)
        return "passed" if result.passed?
        return "failed" if result.failed?
        return "undefined" if result.undefined?
        return "unknown" if result.unknown?
        return "skipped" if result.skipped?
        return "pending" if result.pending?
      end

      def self.get_result
        Kaya::Results::Result.get(self.id)
      end

      # Returns result execution data if exist. Else returns an empty hash
      def self.get_data
        self.is_there_result? ? self.get_result.execution_data : {}
      end

      # Conntects to database if not connected
      def self.ensure_db_connection
        Kaya::Support::Configuration.get
        Kaya::Database::MongoConnector.new(Kaya::Support::Configuration.db_connection_data) unless Kaya::Database::MongoConnector.connected?
      end

    end
  end
end
