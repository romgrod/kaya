module Kaya
  module Suites
    class Suite

      attr_accessor :id,
      :name,
      :branch,
      :status,
      :command,
      :custom,
      :info,
      :last_execution,
      :last_result,
      :active

      # First, try to get suite info from mongo.
      # If it does not exist creates a new one with default values
      def initialize suite_data = nil
        $K_LOG.debug "[#{suite_data["_id"]}:#{suite_data["name"]}] Creating suite object " if $K_LOG
        if suite_data.is_a? Hash
          @id             = suite_data["_id"]
          @name           = suite_data["name"]
          @branch         = suite_data["branch"]
          @status         = suite_data["status"]
          @command        = suite_data["command"]
          @custom         = suite_data["custom"] || []
          @info           = suite_data["info"] || ""
          @last_execution = suite_data["last_execution"]
          @last_result    = suite_data["last_result"]
          @active         = suite_data["active"]

        else
          $K_LOG.error "Creting suite object. Argument is not a hash" if $K_LOG
          raise "Suite data not defined correctly. Expecting info about suite"
        end
      end


      def api_response
        response = suite_data_structure
        response["results"]={
          "size" => number_of_results,
          "ids" => all_results_ids
        }
        response
      end

      def self.get suite_id
        $K_LOG.debug "Getting suite data for [id:#{suite_id}]"  if $K_LOG
        suite_data = Kaya::Database::MongoConnector.suite_data_for suite_id
        suite_data = suite_data.to_h if respond_to? :to_h
        new(suite_data) if suite_data
      end

      def self.get_suite_with name
        self.new(Kaya::Database::MongoConnector.suite_data_for_name(name))
      end

      def self.new_suite(suite_name)
        $K_LOG.debug "Defining new suite [#{suite_name}]" if $K_LOG
        suite_data = {
          "_id" => Kaya::Database::MongoConnector.generate_id,
          "name" => suite_name,
          "branch" => Kaya::Support::Git.actual_branch,
          "status" => "READY",
          "active" => true
        }
        self.new(suite_data)

      end

      def suite_data_for suite_name
        Kaya::Database::MongoConnector.suite_data_for(suite_name)
      end

      # Returns the structure of a suite data
      # @return [Hash] data structure
      def suite_data_structure
        {
          "_id" => id,
          "name" => name,
          "branch" => branch,
          "status" => status,
          "command" => command,
          "custom" => custom,
          "info"  => info,
          "last_execution" => last_execution,
          "last_result" => last_result,
          "active" => active
        }
      end

      def has_custom_params?
        !@custom.empty?
      end

      # Returns an array of those required custom params
      # This is for start execution validations
      # @return [Array]
      def required_custom_params
        custom.select{|param| param["required"]}.map{|param| param["name"]}
      end

      def has_info?
        not @info.empty?
      end

      def activate!
        @active= true
        $K_LOG.debug "[#{@id}:#{@name}] Activated" if $K_LOG
        self.save!
      end

      def deactivate!
        @active = false
        $K_LOG.debug "[#{@id}:#{@name}] Deactivated" if $K_LOG
        self.save!
      end

      def is_ready?
        status == "READY"
      end

      def is_running?
        status == "RUNNING"
      end

      def set_ready!
        @status = "READY"
        $K_LOG.debug "[#{@id}:#{@name}] Marked as ready" if $K_LOG
        self.save!
      end

      def set_running!
        @status= "RUNNING"
        $K_LOG.debug "[#{@id}:#{@name}] Marked as running" if $K_LOG
        self.save!
      end

      def number_of_results
        all_results.size
      end

      def all_results_ids
        all_results.inject([]){|res, result| res << result["_id"]}
      end

      def all_results
        Kaya::Database::MongoConnector.results_for(id)
      end

      def has_results?
        number_of_results > 0
      end

      def save!
        if Kaya::Database::MongoConnector.suite_data_for(id)
          Kaya::Database::MongoConnector.update_suite(suite_data_structure)
        else
          Kaya::Database::MongoConnector.insert_suite(suite_data_structure)
        end
        $K_LOG.debug "[#{@id}:#{@name}] Suite saved" if $K_LOG
      end

      # If test suites ir running
      def check_last_result!
        if self.is_running? and (result = Results::Result.get(@last_result))
            $K_LOG.debug "[#{@id}:#{@name}] Checking last result" if $K_LOG
            self.set_ready! if (result.update_values! or result.finished?)
            $K_LOG.debug "[#{@id}:#{@name}] Done" if $K_LOG
        end
      end

    end

  end
end