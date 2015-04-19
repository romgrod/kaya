module Kaya
  module Commands
    def self.reset
      $K_LOG.debug "#{self}:#{__method__}" if $K_LOG
      begin

        Kaya::Support::Configuration.get
        Kaya::Database::MongoConnector.new(Kaya::Support::Configuration.db_connection_data)

        print "\nCleanning database..."

        Kaya::Database::MongoConnector.drop_collections
        print "Done!\n\n"

        print "\nCleanning project..."

        Kaya::Support::FilesCleanner.start!
        print "Done!\n\n"

        if Kaya::Support::Configuration.use_git?

            Kaya::Support::Git.pull

            Kaya::Suites.update_suites

        else # NO GIT USAGE

          Kaya::Suites.update_suites

        end

        puts "PROFILES LOADED CORRECTLY \n\nRun `kaya start`"

      rescue => e
        puts "CANNOT CLEAN SYSTEM\n#{e}\n\n#{e.backtrace}"
      end
    end
  end
end