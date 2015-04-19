require 'kaya'

module Kaya
  module Workers
    class ExecutionChecker
      include Sidekiq::Worker
        def perform(suite_id)

          Kaya::Support::Configuration.get
          Kaya::Database::MongoConnector.new Kaya::Support::Configuration.db_connection_data

          suite = Kaya::Suites::Suite.get(suite_id)
          begin
            suite.check_last_result!
            sleep 10
          end while not suite.is_ready?
        end
    end
  end
end
