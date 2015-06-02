module Kaya
  module API
    module Tasks

      # @param [hash] options = {:running, :active}
      def self.list(options ={})

        start = Time.now.to_f

        response = {
          "project_name" => Dir.pwd.split("/").last,
          "size" => 0,
          "tasks" => [],
          "message" => nil
        }
        tasks = if options[:running]
          response["request"] = "Running Tasks"
          Kaya::Tasks.running_tasks
        else
          response["request"] = options[:type] ? "#{options[:type].capitalize} Tasks" : "Tasks"
          Kaya::Tasks.tasks options[:type]
        end


        if tasks.size.zero?
          response["message"] = options[:running] ? "Running tasks not found" : "Tasks not found"
        else

          tasks = tasks.map do |task|
            results_for_task = Kaya::Results.results_ids_for task["_id"]
            task["results"]={
              "size" => results_for_task.size,
              "ids" => results_for_task
            }
            task
          end

          response["tasks"] = tasks
          $K_LOG.debug "#{tasks.size} retrieved in (#{Time.now.to_f - start} s)" if $K_LOG

          response["size"] = tasks.size
        end
        response
      end
    end
  end
end
