module Kaya
  module Tasks
    class Task

      attr_accessor :id,
      :name,
      :branch,
      :type,
      :status,
      :command,
      :custom,
      :info,
      :last_execution,
      :last_result,
      :active

      attr_reader :max_execs

      # First, try to get task info from mongo.
      # If it does not exist creates a new one with default values
      def initialize task_data = nil
        $K_LOG.debug "[#{task_data["_id"]}:#{task_data["name"]}] Creating task object " if $K_LOG
        if task_data.is_a? Hash
          @id             = task_data["_id"]
          @name           = task_data["name"]
          @branch         = task_data["branch"]
          @type           = task_data["type"]
          @status         = task_data["status"]
          @command        = task_data["command"]
          @custom         = task_data["custom"] || []
          @info           = task_data["info"] || ""
          @last_execution = task_data["last_execution"]
          @last_result    = task_data["last_result"] || Kaya::Support::Configuration.maximum_execs_per_task
          @active         = task_data["active"]
          @max_execs      = task_data["maximum_execs"]

        else
          $K_LOG.error "Creting task object. Argument is not a hash" if $K_LOG
          raise "Task data not defined correctly. Expecting info about task"
        end
      end


      def api_response
        response = task_data_structure
        response["results"]={
          "size" => number_of_results,
          "ids" => all_results_ids
        }
        response
      end

      def self.get task_id
        $K_LOG.debug "Getting task data for [id:#{task_id}]"  if $K_LOG
        task_data = Kaya::Database::MongoConnector.task_data_for task_id
        task_data = task_data.to_h if respond_to? :to_h
        new(task_data) if task_data
      end

      def self.get_task_with name
        self.new(Kaya::Database::MongoConnector.task_data_for_name(name))
      end

      def self.new_task(task_name, maximum_execs=Kaya::Support::Configuration.maximum_execs_per_task, type=nil)

        $K_LOG.debug "Defining new task [#{task_name}]" if $K_LOG
        task_data = {
          "_id" => Kaya::Database::MongoConnector.generate_id,
          "name" => task_name,
          "branch" => Kaya::Support::Git.actual_branch,
          "type" => type,
          "status" => "READY",
          "active" => true,
          "maximum_execs" => maximum_execs
        }
        self.new(task_data)

      end

      def task_data_for task_name
        Kaya::Database::MongoConnector.task_data_for(task_name)
      end

      # Returns the structure of a task data
      # @return [Hash] data structure
      def task_data_structure
        {
          "_id" => id,
          "name" => name,
          "branch" => branch,
          "type" => type,
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

      def test?
        self.type == "test"
      end

      def activate!
        raise "activate! => DEPRECATED #{__FILE__}:#{__LINE__}"
        # @active= true
        # $K_LOG.debug "[#{@id}:#{@name}] Activated" if $K_LOG
        # self.save!
      end

      def deactivate!
        raise "deactivate! => DEPRECATED #{__FILE__}:#{__LINE__}"
        # @active = false
        # $K_LOG.debug "[#{@id}:#{@name}] Deactivated" if $K_LOG
        # self.save!
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
        if Kaya::Database::MongoConnector.task_data_for(id)
          Kaya::Database::MongoConnector.update_task(task_data_structure)
        else
          Kaya::Database::MongoConnector.insert_task(task_data_structure)
        end
        $K_LOG.debug "[#{@id}:#{@name}] Task saved" if $K_LOG
      end

      # If test tasks ir running
      def check_last_result!

        raise "NO SE PUEDE USAR MAS ESTO, AHORA HAY QUE CHEQUEAR POR SEPARADO"


      end

    end

  end
end