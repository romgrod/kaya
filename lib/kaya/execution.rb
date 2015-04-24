module Kaya
  class Execution


    # Run/Execute the commmand
    # @param [Hash] execution_data = { :suite_id, :label }
    def self.run! execution_request_data

      if Kaya::Support::Configuration.use_git?
        Kaya::Support::Git.reset_hard and Kaya::Support::Git.pull
        $K_LOG.debug "Git pulled" if $K_LOG
      end


        result = Kaya::Results::Result.new(execution_request_data)
        $K_LOG.debug "Result created with id => #{result.id}" if $K_LOG

        result_id = result.id

      if execution_request_data["type"] == "cucumber"
        $K_LOG.debug "Execution type: Cucumber" if $K_LOG
        Kaya::Cucumber::Task.run(result)

        $K_LOG.debug "Task started" if $K_LOG


        # Performed by background job
        # if result = Results::Result.get(result_id)

        #   result.append_result_to_console_output!

        #   result.save_report!

        #   result.get_summary!

        #   result.get_status!

        #   result =  nil
        # end

        result_id

      else # ANOTHER TYPE OF EXECUTION
        $K_LOG.debug "Execution type: #{execution_request_data[:type]}" if $K_LOG
        puts "TODO: Another type of execution (no cucumber execution)"

        Time.now.to_i # must return an id number

      end
    end






  end
end