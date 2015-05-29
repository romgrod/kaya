module Kaya
  module Results

    def self.all_results_for suite_id
      Kaya::Database::MongoConnector.results_for suite_id
    end

    def self.results_ids_for suite_id
      all_results_for(suite_id).map do |result|
        result["_id"]
      end
    end

    def self.running_results_for_suite_id suite_id
      Kaya::Database::MongoConnector.running_results_for_suite_id suite_id
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
    def self.reset_defuncts
      Kaya::Database::MongoConnector.all_results.select do |result|
        ["started","running"].include? result["status"]
      end.each do |result|
        Kaya::Support::Processes.kill_by_result_id(result["_id"])
      end.each do |result|
        result = Kaya::Results::Result.get(result["_id"])
        result.reset!

      end
    end
  end
end