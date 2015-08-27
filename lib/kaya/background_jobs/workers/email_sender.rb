require 'kaya'

module Kaya
  module Workers
    class EmailSender
      include Sidekiq::Worker
      def perform(result_id)

        puts result_id

        Kaya::Support::Configuration.get
        Kaya::Database::MongoConnector.new Kaya::Support::Configuration.db_connection_data

        result = Kaya::Results::Result.get(result_id)
        puts result

      end
    end
  end
end