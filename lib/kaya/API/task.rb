module Kaya
  module API

    class Task

      def self.info(task_id)
        task_id = task_id.to_i if task_id.respond_to? :to_i
        response = {
          "project_name" => Dir.pwd.split("/").last,
          "task" => nil,
          "message" => nil
        }
        task = Kaya::Tasks::Task.get(task_id)
        $K_LOG.debug "SUITE => #{task}"
        if task.nil?
          response["message"] = "Task not found"
        else
          response["task"] = task.api_response
        end
        response
      end

      def self.info_for_name task_name
        $K_LOG.debug "task_name received on info_for_name #{task_name}"
        task_id = Kaya::Tasks.task_id_for(task_name)
        $K_LOG.debug "task_id obtained on 'Kaya::Tasks.task_id_for' #{task_id}"
        self.info(task_id)
      end


      def self.status task_id
        response = info(task_id)

        output = if response["message"]
          {
            "task_id" => nil,
            "message" => response["message"]
          }
        else
          {
            "task_id" => response["task"]["_id"],
            "status" => response["task"]["status"]
          }
        end
        output
      end
    end
  end
end

