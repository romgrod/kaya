module Kaya
  class Execution



    def self.run! execution_request_data

      if Kaya::Support::Configuration.use_git?
        Kaya::Support::Git.reset_hard and Kaya::Support::Git.pull
        $K_LOG.debug "Git pulled" if $K_LOG
      end
        result = Kaya::Results::Result.new(execution_request_data)
        $K_LOG.debug "Result created with id => #{result.id}" if $K_LOG

        result.save!

        $K_LOG.debug "Execution type #{result.task_type}" if $K_LOG
        Kaya::Workers::Executor.perform_async(result.id)
        $K_LOG.debug "#{result.task_type.capitalize}(#{result.id}) started" if $K_LOG
        result.id
    end
  end
end