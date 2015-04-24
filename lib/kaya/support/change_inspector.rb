module Kaya
  module Support
    module ChangeInspector

      # Evaluates if code has been changed. If yes, performs a git reset hard and git pull
      # Update commit log into Database and return true
      # Returns true if there is a change in code.
      # Consider true if git usage is false
      # @return [Boolean]

      def self.is_there_a_change?
        if Kaya::Support::Configuration.use_git?
          if Kaya::Database::MongoConnector.last_commit != (last_repo_commit  = Kaya::Support::Git.last_commit)
            $K_LOG.debug "Git has been changed. Perform code update" if $K_LOG
            Kaya::Support::Git.reset_hard_and_pull
            Kaya::Database::MongoConnector.insert_commit(last_repo_commit)
            $K_LOG.debug "Commit log updated on database" if $K_LOG
            true
          else
            $K_LOG.debug "No git changes" if $K_LOG
            false
          end
        else
          true
        end
      end

      def self.is_there_gemfile_lock?
        begin
          IO.read("#{Dir.pwd}/Gemfile.lock")
        rescue
          false
        end
      end
    end
  end
end