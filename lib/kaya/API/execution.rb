module Kaya
  module API
    class Execution
      def self.start suite_name, query_string
        $K_LOG.debug "Starting suite #{suite_name}" if $K_LOG

        git_log = Kaya::Support::Configuration.use_git? ? Kaya::Support::Git.log_last_commit : ""


        unless query_string.empty?

          execution_name = query_string.delete("execution_name") if query_string.has_key? "execution_name"
          query_string.each_pair do |param, value|
            query_string.delete(param) if (value =~ /Enter/ or value.nil? or value == "")
          end
          custom_params = query_string || {}

        else
          execution_name =  nil
          custom_params = {}
        end

        error = false

        if Kaya::Suites.is_there_suite_with? suite_name
          $K_LOG.debug "Starting working with suite #{suite_name}" if $K_LOG

          suite = Kaya::Suites::Suite.get_suite_with(suite_name)

          suite_id = suite.id

          # if Kaya::Suites.execution_running_for_suite(suite_name) < suite.maximum_execs
          if Kaya::Suites.execution_running_for_suite(suite_name) < 3 # HARDCODED

            $K_LOG.debug "Suite #{suite_name} is ready to run" if $K_LOG

            execution_request_data = {
              "type"            => "cucumber",
              "suite"           => {"id" => suite.id, "name" => suite.name},
              "execution_name"  => execution_name,
              "custom_params"   => custom_params,
              "git_log"         => git_log
            }

            suite.last_result = Kaya::Execution.run!(execution_request_data) # Returns result_id

            suite.set_running!

            suite.save!

            $K_LOG.debug "Suite #{suite_name} setted as running" if $K_LOG


            execution_id = suite.last_result
            started = true
            message = "Suite%20#{suite.name}%20started"
            status = 200
            $K_LOG.debug "Suite #{suite.name} started" if $K_LOG

          else

            execution_id = nil
            started = false
            status = 423
            message = "Max number of concurrent execution reached. Please wait until one is finalized"
            $K_LOG.error "Cannot run more than #{suite.maximum_execs} executions simultaneously" if $K_LOG
          end

        else # No suite for  suite_name
          $K_LOG.error "Suite not found for name #{suite_name}" if $K_LOG
          started = false
          execution_id = suite_id = nil
          status = 404
          error = true
          message = "Suite #{suite_name} not found"
        end
          {
            "suite" => {
              "name" => suite_name,
              "id" => suite_id,
              "started" => started
              },
            "execution_id" => execution_id,
            "message" => message,
            "error" => error,
            "status" => status
          }
      end

      # RESET EXECUTION
      #
      # Kill associated process to the running execution
      # Sets as finished the result and associated suite as READY
      #
      def self.reset(result_id)

        $K_LOG.debug "Reset execution request for #{result_id}"

        result = Kaya::Results::Result.get(result_id)

        suite = Kaya::Suites::Suite.get(result.suite_id)

          if result.process_running? or !result.finished? or !result.stopped?
            begin
              Kaya::Support::Processes.kill_by_result_id(result.id)
              killed = true
              $K_LOG.debug "Execution (id=#{results.id}) killed"
            rescue => e
              $K_LOG.error "#{e}#{e.backtrace}"
            end

            begin
              Kaya::Support::FilesCleanner.delete_report_which_has(result.id)
              $K_LOG.debug "Execution files(id=#{result.id}) cleanned"
              cleanned = true
            rescue
            end

            result.append_result_to_console_output!
            result.save_report!
            result.reset!("forced"); $K_LOG.debug "Execution stopped! Kaya restarted"
            result.show_as = "pending"
            result.save!
            # Reset if suite is setted as "RUNNING" and its result_id value corresponds to the result reset request
            suite.set_ready! if suite.last_result == result.id
            if killed and cleanned
              {"message" => "Execution stopped"}
            else
              {"message" => "Could not stop execution. Process killing: #{killed}. Files cleanned: #{celanned}"}
            end
          end
        # else
        #   {"message" => "You are not the owner of this execution"}
        # end
      end

    end
  end
end