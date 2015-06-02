module Kaya
  module API
    class Result
      def self.get_for_task(task_id)
        task = Kaya::Tasks::Task.get(task_id)
        if task
          {
            "project_name" => Dir.pwd.split("/").last,
            "task" => {id:task.id, name:task.name},
            "results" => results_list_for(task.id)
          }
        else
          {"results" => results_list}
        end
      end

      def self.results_list_for(task_id)
        task_results = Kaya::Results.results_ids_for(task_id)
        task_results.map do |result_id|
          info(result_id)
        end
      end

      def self.info(result_id)
        result = Kaya::Results::Result.get(result_id)
        if result
          result.api_response
        else
          {"message" => "Result #{result_id} not found"}
        end
      end

      def self.data result_id
        result = self.info result_id
        {"type" => "result", "_id" => result["_id"], "status" => result["status"], "execution_data" => result["execution_data"]}
      end

      def self.status result_id
        result = self.info result_id
        {"type" => "result", "status" => result["status"]}
      end

      # def self.results_list

      # end

    end
  end
end