module Kaya
  module Commands
    def self.reset_tasks
      $K_LOG.debug "#{self}:#{__method__}" if $K_LOG
      begin

        Kaya::Support::Configuration.get

        Kaya::Database::MongoConnector.new(Kaya::Support::Configuration.db_connection_data)

        print "\nCleanning tasks from database..."

        Kaya::Database::MongoConnector.drop_collections
        print "Done!\n\n"

        print "\nCleanning project..."

        Kaya::Support::FilesCleanner.start!
        print "Done!\n\n"

      rescue => e
        puts "CANNOT CLEAN SYSTEM\n#{e}\n\n#{e.backtrace}"
      end
    end
  end
end