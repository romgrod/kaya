module Kaya
  module API
    module Tasks

      def self.set data

        data = self.sanitize data

        response = case data["action"]
        when "new"
          Kaya::Tasks::Task.validate_and_create(data)
        when "edit"
          Kaya::Tasks::Task.validate_and_update(data)
        when "delete"
          Kaya::Tasks::Task.delete_this(data)
        end
        response
      end

      def self.sanitize data
        data["max_execs"] = data["max_execs"].to_i if data["max_execs"].respond_to? :to_i
        data["cucumber"] = data["cucumber"] == "on"
        data["cucumber_report"] = data["cucumber_report"] == "on"
        data["information"] = nil if data["information"].size.zero?
        data
      end

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
          type = options[:type]
          response["request"] = "Running #{type.capitalize}"
          if type == "task"
            Kaya::Tasks.running_tasks
          else
            Kaya::Tasks.running_tests
          end
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
