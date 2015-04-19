module Kaya
  module API
    class Result
      def self.get_for_suite(suite_id)
        suite = Kaya::Suites::Suite.get(suite_id)
        if suite
          {
            "project_name" => Dir.pwd.split("/").last,
            "suite" => {id:suite.id, name:suite.name},
            "results" => results_list_for(suite.id)
          }
        else
          {"results" => results_list}
        end
      end

      def self.results_list_for(suite_id)
        suite_results = Kaya::Results.results_ids_for(suite_id)
        suite_results.map do |result_id|
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