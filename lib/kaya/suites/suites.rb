module Kaya
  module Suites

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

          content.select do |suite_name, command|
            command.include? "runnable=true"
          end.map do |suite_name, command|

            command.gsub!(' runnable=true','').gsub!(', ',',')

            suite_info = command.scan(/info\=\[(.*)\]/).flatten.first

            suite_info.gsub('<br>','\n') if suite_info.respond_to? :gsub

            command.gsub!(/info\=\[(.*)\]/,"")

            custom_params = command.scan(/custom\=\[(.*)\]/).flatten.first

            custom = Kaya::Suites::Custom::Param.new(custom_params)

            command.gsub!(/custom\=\[(.*)\]/,"")

            {"suite_name" => suite_name, "command" => command, "custom" => {}, "info" => suite_info}
          end
        else
          []
        end
      rescue => e
        $K_LOG.error "Suites: #{e}#{e.backtrace}" if $K_LOG
        []
      end
    end

    def self.update_suites
      self.update! if Kaya::Support::ChangeInspector.is_there_a_change? or Kaya::Database::MongoConnector.active_suites.size.zero?
    end

    def self.update!
      $K_LOG.debug "Updating suites" if $K_LOG
      existing_suites_ids = self.suites

      self.cucumber_yml.each do |suite_data|
        # If is there a suite for the given name suite_id will be setted
        # and the id will be deleted from existing_suites_ids
        existing_suites_ids.delete(suite_id = is_there_suite_with?(suite_data["name"]))

        if suite_id # Update
          suite = Kaya::Suites::Suite.get(suite_id)
          suite.name= suite_data["suite_name"]
        else
          suite = Kaya::Suites::Suite.new_suite(suite_data["suite_name"])
        end

        suite.command= suite_data["command"]
        suite.custom = suite_data["custom"]
        suite.info=    suite_data["info"]

        suite.activate! if suite_id
        $K_LOG.debug "[#{suite.id}:#{suite.name}] Suite Updated" if $K_LOG
        suite.save!
      end

      unless existing_suites_ids.empty?
        existing_suites_ids.each do |suite_id|
          # suite = Kaya::Suites::Suite.get(suite_id)
          # suite.deactivate!
          Kaya::Suites.delete! suite_id
        end
      end
    end

    def self.is_there_suite_with? name
      self.suite_id_for name
    end

    # Returns a list of suites id
    # @param [Boolean] actives or not
    # @return [Array] a list of suite ids
    def self.suites active=nil
      $K_LOG.debug "Suites:Getting all suites ids" if $K_LOG
      Kaya::Database::MongoConnector.suites(active)
    end

    # Returns the id for given suite name
    # @param [String] suite name
    # @return [Fixnum] suite id
    def self.suite_id_for(suite_name, active=nil)
      $K_LOG.debug "Suites:Getting suite id for #{suite_name}" if $K_LOG
      Kaya::Database::MongoConnector.suite_id_for(suite_name)
    end

    # Returns the ids for running suites
    # @return [Array] of suite ids
    def self.running_suites
      $K_LOG.debug "Suites: Getting all runnnig suites" if $K_LOG
      # Kaya::Database::MongoConnector.all_suites.select do |suite|
      #   suite["status"] == "RUNNING"
      # end.map{|suite| suite["_id"]}
      Kaya::Database::MongoConnector.running_suites
    end

    def self.execution_running_for_suite suite_name
      Kaya::Database::MongoConnector.running_for_suite(suite_name).size
    end

    def self.reset_statuses
      $K_LOG.debug "Resetting suites status" if $K_LOG
      self.running_suites.each do |suite|
        if suite = Kaya::Suites::Suite.get(suite["_id"])
          if result = Kaya::Results::Result.get(suite.last_result)
            result.update_values! # update_values! true means result got finished status
          end
          suite.set_ready!
        end
      end
    end

    def self.delete! suite_id
      Kaya::Database::MongoConnector.delete_suite suite_id
    end

  end
end