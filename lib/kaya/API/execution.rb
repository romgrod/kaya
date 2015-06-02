module Kaya
  module API
    class Execution
      def self.start task_name, query_string, type = nil
        $K_LOG.debug "Starting task #{task_name}" if $K_LOG

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

        if Kaya::Tasks.is_there_task_with? task_name, type
          $K_LOG.debug "Starting working with task #{task_name}" if $K_LOG

          task = Kaya::Tasks::Task.get_task_with(task_name)

          task_id = task.id

          # if Kaya::Tasks.execution_running_for_task(task_name) < task.maximum_execs
          if Kaya::Tasks.execution_running_for_task(task_name) < 3 # HARDCODED

            $K_LOG.debug "Task #{task_name} is ready to run" if $K_LOG

            execution_request_data = {
              "type"            => "cucumber",
              "task"           => {"id" => task.id, "name" => task.name},
              "execution_name"  => execution_name,
              "custom_params"   => custom_params,
              "git_log"         => git_log
            }

            task.last_result = Kaya::Execution.run!(execution_request_data) # Returns result_id

            task.set_running!

            task.save!

            $K_LOG.debug "Task #{task_name} setted as running" if $K_LOG


            execution_id = task.last_result
            started = true
            message = "Task%20#{task.name}%20started"
            status = 200
            $K_LOG.debug "Task #{task.name} started" if $K_LOG

          else

            execution_id = nil
            started = false
            status = 423
            message = "Max number of concurrent execution reached. Please wait until one is finalized"
            $K_LOG.error "Cannot run more than #{task.maximum_execs} executions simultaneously" if $K_LOG
          end

        else # No task for  task_name
          $K_LOG.error "Task not found for name #{task_name}" if $K_LOG
          started = false
          execution_id = task_id = nil
          status = 404
          error = true
          message = "Task #{task_name} not found"
        end
          {
            "task" => {
              "name" => task_name,
              "id" => task_id,
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
      # Sets as finished the result and associated task as READY
      #
      def self.reset(result_id)

        $K_LOG.debug "Reset execution request for #{result_id}"

        result = Kaya::Results::Result.get(result_id)

        task = Kaya::Tasks::Task.get(result.task_id)

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
            # Reset if task is setted as "RUNNING" and its result_id value corresponds to the result reset request
            task.set_ready! if task.last_result == result.id
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