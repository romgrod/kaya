module Kaya
  module Results

    def self.all_results_for task_id
      Kaya::Database::MongoConnector.results_for task_id
    end

    def self.results_ids_for task_id
      all_results_for(task_id).map do |result|
        result["_id"]
      end
    end

    def self.running_results_for_task_id task_id
      Kaya::Database::MongoConnector.running_results_for_task_id task_id
    end

    def self.all_results_ids
      Kaya::Database::MongoConnector.all_results_ids
    end

    def self.find_for key
      Kaya::Database::MongoConnector.find_results_for_key key
    end

    def self.find_for_status status
      Kaya::Database::MongoConnector.find_results_for_status status
    end

    def self.all_results
      Kaya::Database::MongoConnector.all_results
    end

    def self.find_all_for_key key
      Kaya::Database::MongoConnector.find_results_for_key key
    end

    # Resets all results with running status
    def self.reset!
      Kaya::Database::MongoConnector.running_results.each do |result|
        Kaya::Support::Processes.kill_p(result["pid"])
        Kaya::Results::Result.get(result["_id"]).reset!
      end
    end

  end
end