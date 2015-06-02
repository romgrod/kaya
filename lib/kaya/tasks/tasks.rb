module Kaya
  module Tasks

    def self.cucumber_yml
      $K_LOG.debug "Getting cucumber.yml content" if $K_LOG
      begin
        # Try to open cucumber.yml file from root folder
        content = YAML.load_file("#{Dir.pwd}/cucumber.yml")
      rescue  # Could not find the file
        # Try to open from /config/
        $K_LOG.warn "cucumber.yml file not found"  if $K_LOG
        begin
          content = YAML.load_file("#{Dir.pwd}/config/cucumber.yml")
        rescue # Could not find the file
          $K_LOG.warn "cucumber.yml file not found"  if $K_LOG
          content ={}
        end
      end

      begin
        unless content.empty?

          content.select do |task_name, command|
            command.include? "runnable=true"
          end.map do |task_name, command|

            command.gsub!(' runnable=true','').gsub!(', ',',')

            task_info = command.scan(/info\=\[(.*)\]/).flatten.first

            task_info.gsub('<br>','\n') if task_info.respond_to? :gsub

            command.gsub!(/info\=\[(.*)\]/,"")

            custom_params = command.scan(/custom\=\[(.*)\]/).flatten.first

            custom = Kaya::Tasks::Custom::Param.new(custom_params)

            command.gsub!(/custom\=\[(.*)\]/,"")

            {"task_name" => task_name, "command" => command, "custom" => {}, "info" => task_info}
          end
        else
          []
        end
      rescue => e
        $K_LOG.error "Tasks: #{e}#{e.backtrace}" if $K_LOG
        []
      end
    end

    def self.update_tasks
      self.update! if Kaya::Support::ChangeInspector.is_there_a_change? or Kaya::Database::MongoConnector.active_tasks.size.zero?
    end

    def self.update!
      $K_LOG.debug "Updating tasks" if $K_LOG
      existing_tasks_ids = self.tasks

      self.cucumber_yml.each do |task_data|
        # If is there a task for the given name task_id will be setted
        # and the id will be deleted from existing_tasks_ids
        existing_tasks_ids.delete(task_id = is_there_task_with?(task_data["name"]))

        if task_id # Update
          task = Kaya::Tasks::Task.get(task_id)
          task.name= task_data["task_name"]
        else
          task = Kaya::Tasks::Task.new_task(task_data["task_name"])
        end

        task.command= task_data["command"]
        task.custom = task_data["custom"]
        task.info=    task_data["info"]

        task.activate! if task_id
        $K_LOG.debug "[#{task.id}:#{task.name}] Task Updated" if $K_LOG
        task.save!
      end

      unless existing_tasks_ids.empty?
        existing_tasks_ids.each do |task_id|
          # task = Kaya::Tasks::Task.get(task_id)
          # task.deactivate!
          Kaya::Tasks.delete! task_id
        end
      end
    end

    def self.is_there_task_with? name, type=nil
      self.task_id_for name, type
    end

    # Returns a list of tasks id
    # @param [Boolean] type or not
    # @return [Array] a list of task ids
    def self.tasks type=nil
      $K_LOG.debug "Tasks:Getting all tasks ids" if $K_LOG
      Kaya::Database::MongoConnector.tasks(type)
    end

    # Returns the id for given task name
    # @param [String] task name
    # @return [Fixnum] task id
    def self.task_id_for(task_name, type=nil)
      $K_LOG.debug "Tasks:Getting task id for #{task_name}" if $K_LOG
      Kaya::Database::MongoConnector.task_id_for(task_name, type)
    end

    # Returns the ids for running tasks
    # @return [Array] of task ids
    def self.running_tasks
      $K_LOG.debug "Tasks: Getting all runnnig tasks" if $K_LOG
      # Kaya::Database::MongoConnector.all_tasks.select do |task|
      #   task["status"] == "RUNNING"
      # end.map{|task| task["_id"]}
      Kaya::Database::MongoConnector.running_tasks
    end

    def self.execution_running_for_task task_name
      Kaya::Database::MongoConnector.running_for_task(task_name).size
    end

    def self.reset_statuses
      $K_LOG.debug "Resetting tasks status" if $K_LOG
      self.running_tasks.each do |task|
        if task = Kaya::Tasks::Task.get(task["_id"])
          if result = Kaya::Results::Result.get(task.last_result)
            result.update_values! # update_values! true means result got finished status
          end
          task.set_ready!
        end
      end
    end

    def self.delete! task_id
      Kaya::Database::MongoConnector.delete_task task_id
    end

  end
end