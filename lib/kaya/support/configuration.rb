module Kaya
  module Support
    class Configuration

      attr_reader :input

      def self.get
        $K_LOG.debug "Creating configuration object" if $K_LOG

        if self.config_file_exists?
          @@input = Kaya::Support::Update.kaya_conf
        else
          @@input = self.default_input
          puts "Error loading kaya_conf. Using default values".colorize(:red)
        end
      end

      def self.default_input
        $K_LOG.debug "#{self.class}Setting default input (from template)" if $K_LOG
        JSON.parse(IO.read(self.path_template))
      end

      def self.path
        "#{Dir.pwd}/kaya/kaya_conf"
      end

      def self.path_template
        File.expand_path("../../", __FILE__) + "/generators/templates/kaya_conf.tt"
      end

      def self.project_name
        $K_LOG.debug "Project name: #{Dir.pwd.split("/").last}"
        "#{Dir.pwd.split("/").last}"
      end

      def self.project_name= value
        @@project_name = value
      end

      def self.project_name
        @@project_name
      end

      def self.hostname
        @@input['HOSTNAME'] || 'localhost'
      end

      # Returns the configured port. If it isn't a number, port 8080 will be returned by defualt
      # @return [Fixnum] port number
      def self.port
        self.is_a_number?(@@input["APP_PORT"]) ? @@input["APP_PORT"] : 8080
      end

      def self.config_file_exists?
        File.exist? self.path
      end

      def self.project_name
        @@input['PROJECT_NAME'] || 'A project using Kaya'
      end

      def self.project_url
        url = @@input['PROJECT_URL'] == "http://your.project.url" ? "" : @@input['PROJECT_URL']
        url.empty? ? Kaya::Support::Git.remote_url : url
      end

      def self.db_type
        @@input["DATABASE"]['TYPE'] || 'mongodb'
      end

      def self.db_host
        @@input["DATABASE"]['HOST'] || 'localhost'
      end

      def self.db_port
        @@input["DATABASE"]['PORT'] || 27017
      end

      def self.db_username
        @@input["DATABASE"]["USERNAME"] || nil
      end

      def self.db_pass
        @@input["DATABASE"]["PASSWORD"] || nil
      end

      def self.db_connection_data
        {
          :host => self.db_host,
          :port => self.db_port,
          :username => self.db_username,
          :pass => self.db_pass
        }
      end

      def self.maximum_execs_per_suite
        @@input["MAXIMUM_EXECS_PER_SUITE"] || 3
      end

      def self.notification?
        self.notification_username and self.notification_password and self.use_gmail?
      end

      def self.notifications_to
        self.recipients
      end

      def self.recipients
        self.is_email_correct? ? @@input['NOTIFICATION']['RECIPIENTS'] : ''
      end

      def self.notification_username
        @@input['NOTIFICATION']['USERNAME']
      end

      def self.notification_password
        @@input['NOTIFICATION']['PASSWORD']
      end

      def self.refresh_time
        self.is_a_number?(@@input['REFRESH_TIME']) ? @@input['REFRESH_TIME'] : 0
      end

      def self.refresh?
        !self.refresh_time.zero?
      end

      def self.use_gmail?
        self.is_boolean? @@input['USE_GMAIL'] ? @@input['USE_GMAIL'] : false
      end

      def self.is_email_correct?
        begin
          !@@input['NOTIFICATION']['RECIPIENTS'].scan(/\w+@[a-zA-Z]+?\.[a-zA-Z]{2,6}/).empty?
        rescue
          false
        end
      end

      def self.attach_report?
        value = @@input['NOTIFICATION']['ATTACH_REPORT']
        self.is_boolean? value ? value : false
      end



      def self.is_a_number? value
        !"#{value}".scan(/\d+/).empty?
      end

      def self.is_boolean? object
        [TrueClass, FalseClass].include? object.class
      end

      def self.use_git?
        self.validate_use_git_configuration_value
        @@input['USE_GIT']
      end

      def self.validate_use_git_configuration_value
        raise "You have to set USE_GIT config with true or false. Has #{@@input['USE_GIT']}" unless is_boolean? @@input['USE_GIT']
      end

      def self.formatted_datetime
        @@input['FORMAT_DATETIME'] || "%d/%m/%Y %H:%M:%S"
      end

      def self.company
        if @@input['FOOTER'].is_a? String
          @@input['FOOTER']
        else
          ""
        end
      end

      # After this period of time (in seconds) Kaya will show a stop execution button on result report and results list
      def self.inactivity_timeout
        self.is_a_number?(@@input["INACTIVITY_TIMEOUT"]) ? @@input["INACTIVITY_TIMEOUT"] : 60
      end

      # After this period of time (in seconds) Kaya will kill process execution automatically
      def self.execution_time_to_live
        self.is_a_number?(@@input["KILL_INACTIVE_EXECUTIONS_AFTER"]) ? @@input["KILL_INACTIVE_EXECUTIONS_AFTER"] : 3600
      end

      def self.kill_after_time?
        self.execution_time_to_live > 0
      end

      def self.reset_execution_availability?
        inactivity_timeout > 0
      end

      def self.auto_execution_id
        if @@input.has_key? "AUTO_EXECUTION_ID"
          if @@input["AUTO_EXECUTION_ID"]["datetime"]
            Time.now.strftime(@@input["AUTO_EXECUTION_ID"]["format"])
          else
            @@input["AUTO_EXECUTION_ID"]["default"]
          end
        end
      end

      def self.headless?
        if self.is_boolean? @@input["HEADLESS"]["active"]
          "xvfb-run --auto-servernum --server-args='-screen 0, #{self.resolution}x#{self.size}' " if @@input["HEADLESS"]["active"]
        end

        # begin
        #   @@input["HEADLESS"]["active"] if self.is_boolean? @@input["HEADLESS"]["active"]
        # rescue
        #   false
        # end
      end

      # Returns value for screen resolution
      # @return [String] resolution like 1024x768
      def self.resolution
        @@input["HEADLESS"]["resolution"]
      end

      # Returns value for screen size.
      # This is used by xvfb configuration
      # @return [String] value in inches
      def self.size
        @@input["HEADLESS"]["size"]
      end

      def self.pretty_configuration_values
        output = self.configuration_values
        JSON.pretty_generate(output).gsub("\"******\"", "******")
      end

      def self.configuration_values
        output = Marshal.load(Marshal.dump(@@input))
        output["DATABASE"]["USERNAME"] = "******"
        output["DATABASE"]["PASSWORD"] = "******"
        output["NOTIFICATION"]["USERNAME"] = "******"
        output["NOTIFICATION"]["PASSWORD"] = "******"
        output
      end

      def self.show_configuration_values
        puts "

    * Configuration values loaded at starting Kaya:

  #{self.pretty_configuration_values}"
      end

    end
  end
end