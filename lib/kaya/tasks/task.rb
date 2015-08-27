module Kaya
  module Tasks
    class Task

      # Task means what a user can Run. It coul be a test or a tests suites according to the test organization and the used framework
      # There are two types of task: A task properly said and a test.
      # A platform can be specified. It could be one of following:
      #    "bash" => Aimed to run bash commands
      #    "ruby" => When you want to run ruby code
      #    "java" => Well, if you wanto to do it, poor you :P
      #

      attr_accessor :id,
      :name,
      :branch,
      :type,
      :platform,
      :framework,
      :status,
      :command,
      :custom_params,
      :information,
      :cucumber,
      :max_execs,
      :running_execs


      def self.valid_types
        ["task","test"]
      end

      # First, try to get task info from mongo.
      # If it does not exist creates a new one with default values
      def initialize task_data = nil
        $K_LOG.debug "[#{task_data["_id"]}:#{task_data["name"]}] Creating task object " if $K_LOG
        if task_data.is_a? Hash
          @id               = task_data["_id"]
          @name             = task_data["name"]
          @branch           = task_data["branch"]
          @type             = task_data["type"] || "task"
          @platform         = task_data["platform"] || "command line"
          @framework        = task_data["framework"]
          @status           = task_data["status"]
          @command          = task_data["command"]
          @custom_params    = task_data["custom_params"] || []
          @information      = task_data["information"]
          @running_execs    = []
          @cucumber         = task_data["cucumber_report"]
          @cucumber_report  = task_data["cucumber"]
          @max_execs        = task_data["max_execs"] || Kaya::Support::Configuration.maximum_execs_per_task

        else
          $K_LOG.error "Creting task object. Argument is not a hash" if $K_LOG
          raise "Task data not defined correctly. Expecting info about task"
        end
        save!
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

      def self.new_task(data)

        $K_LOG.debug "Defining new task [#{data["name"]}]" if $K_LOG
        task_data = {
          "_id" => Kaya::Database::MongoConnector.generate_id,
          "name" => data["name"],
          "command" => data["command"],
          "type" => data["type"],
          "platform" => data["platform"],
          "information" => data["information"],
          "cucumber" => data["cucumber"],
          "branch" => Kaya::Support::Git.actual_branch,
          "status" => "READY",
          "max_execs" => data["max_execs"],
          "custom_params" => data["custom_params"]
        }
        self.new(task_data)
      end

      def self.validate_and_create(data)
        errors = self.validate(data)
        return { success:false, message:errors.join(" ")} unless errors.empty?
        if self.new_task(data)
          {action:"create", success:true, message:"#{data['type'].capitalize} #{data["name"]} created"}
        else
          {action:"create", success:false, message:"#{data['type'].capitalize} #{data["name"]} could not be created"}
        end

      end

      def self.validate(data)

        # cucumber value must be boolean
        errors = []
          if data["action"] == "edit"
            errors << self.validate_name_with_id(data["name"],data["_id"])
          else
            errors << self.validate_name(data["name"])
          end

          errors << self.validate_max_execs(data["max_execs"])

          errors << self.validate_type(data["type"])

          errors << self.validate_risk_command(data["command"])
          errors.compact
      end

      def self.validate_and_update(data)

      end

      def self.delete_this(data)
        existing_id = Kaya::Tasks.task_id_for data["name"]
        if existing_id == data["_id"]
          if Kaya::Database::MongoConnector.delete_task data["_id"]
            {action:"delete", success:true, message:"Task #{data['_id']} with name #{data["name"]} deleted"}
          else
            {action:"delete", success:false, message:"Could not delete task #{data['_id']} with name #{data["name"]}"}
          end
        end
      end

      # task name must be unique
      def self.validate_name(name)
        return "There is another task with '#{name}' name." if Kaya::Tasks.is_there_task_with? name
      end

      def self.validate_name_with_id(name, id)
        if Kaya::Tasks.is_there_task_with? name
          existing_id = Kaya::Tasks.task_id_for name
          return "There is another task with '#{name}' name." if existing_id != id
        end
      end

      # max_execs could not be greater than global max exec
      def self.validate_max_execs max_execs
        return "Maximum executions cannot be greater than #{Kaya::Support::Configuration.max_execs}" if max_execs > Kaya::Support::Configuration.max_execs
      end

      # type could be only task or test
      def self.validate_type type
        return "#{type} type is not permited." unless self.valid_types.include? type
      end

      # command must be evaluated for risks
      def self.validate_risk_command command
        return "Your commands seems to be unsecure" unless Kaya::Support::Risk.secure? command

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
          "custom_params" => custom_params,
          "information"  => information,
          "running_execs" => running_execs,
          "max_execs" => max_execs,
          "cucumber" => cucumber,
          "platform" => platform
        }
      end

      def has_custom_params?
        !@custom_params.empty?
      end

      # Returns an array of those required custom params
      # This is for start execution validations
      # @return [Array]
#     # def required_custom_params
#     #   all_required = Kaya::Task::Custom::Params.all_required_ids
#     #   custom_params.select{|param| all_required.include? param["_id"]}.map{|param| param["name"]}
#     # end

      def has_info?
        not @information.empty?
      end

      def test?
        self.type == "test"
      end

      # def activate!
      #   raise "activate! => DEPRECATED #{__FILE__}:#{__LINE__}"
      #   # @cucumber= true
      #   # $K_LOG.debug "[#{@id}:#{@name}] Activated" if $K_LOG
      #   # self.save!
      # end

      # def deactivate!
      #   raise "deactivate! => DEPRECATED #{__FILE__}:#{__LINE__}"
      #   # @cucumber = false
      #   # $K_LOG.debug "[#{@id}:#{@name}] Deactivated" if $K_LOG
      #   # self.save!
      # end

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

      def push_exec result_id
        @running_execs << result_id
        self.save!
      end

      def delete_exec result_id
        @running_execs.delete result_id
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