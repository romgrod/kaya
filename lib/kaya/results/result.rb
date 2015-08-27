module Kaya
  module Results
    class Result


      attr_accessor\
        :id,
        :started_at,
        :saw,
        :task,
        :task_name,
        :execution_name,
        :command,
        :custom_params,
        :execution_data,
        :kaya_command,
        :html_report,
        :finished_at,
        :status,
        :summary,
        :results_details,
        :show_as,
        :kaya_report_file_name,
        :console_output_file_name,
        :console_output,
        :git_log,
        :pid,
        :last_check_time,
        :configuration_values,
        :timeout,
        :started_message

      attr_reader :console_output


      def initialize data_for_result

        if data_for_result["_id"]
          # It comes from mongo because there is a result id
          @id                       = data_for_result["_id"]
          load_values(data_for_result)

        else # It comes from a new execution request
          @id = Kaya::Database::MongoConnector.generate_id
          @task                     = data_for_result['task']
          @execution_name           = data_for_result["execution_name"] || ""
          @custom_params            = data_for_result["custom_params"]
          @git_log                  = data_for_result["git_log"]
          @started_message          = data_for_result["started_message"]
          @started_at               = now_in_seconds
          @finished_at              = nil
          @status = @summary        = "started"
          @timeout                  = nil
          @show_as                  = "pending"
          @html_report              = ""
          @results_details          = {"duration" => 0, "passed"=>[], "failed" =>[], "undefined" => [], "unknown"=>[], "skipped" => [], "pending" => []}

          # Save task info
          task_data                 = Kaya::Database::MongoConnector.task_data_for(@task["id"])
          @command                  = data_for_result['command']
          @task_name                = task_data["name"]
          @command                  = task_data["command"]
          @console_output           = ""
          @last_check_time          = now_in_seconds
          @execution_data           = {}
          @configuration_values     = Kaya::Support::Configuration.pretty_configuration_values
          create_output_dir
        end
      end

      def load_values data
        data.each_pair do |var, value|
          begin
            send("#{var}=",value) if send("#{var}").nil?
          rescue; end
        end
      end

      def self.get(result_id)
        result_data = Kaya::Database::MongoConnector.result_data_for_id(result_id)
        new(result_data) if result_data
      end


      def result_data_structure
        {
          "_id"                       => id,
          "task"                      => @task,
          "execution_name"            => execution_name,
          "command"                   => command,
          "custom_params"             => custom_params,
          "kaya_command"              => kaya_command,
          "started_message"           => started_message,
          "kaya_report_file_name"     => kaya_report_file_name,
          "html_report"               => html_report,
          "started_at"                => started_at,
          "finished_at"               => finished_at,
          "status"                    => status,
          "timeout"                   => timeout,
          "summary"                   => summary,
          "results_details"           => results_details,
          "show_as"                   => show_as,
          "console_output_file_name"  => console_output_file_name,
          "console_output"            => console_output,
          "git_log"                   => git_log,
          "saw"                       => saw,
          "pid"                       => pid,
          "last_check_time"           => last_check_time,
          "execution_data"            => execution_data,
          "configuration_values"      => configuration_values
        }
      end

      def has_started_message?
        !@started_message.nil?
      end

      def get_started_message!
        text = self.started_message
        @started_message = nil
        self.save!
        text
      end

      def api_response
        data = result_data_structure
        data["has_report"] = self.has_report?
        data["elapsed_time"] = self.elapsed_time
        # List of fields to omit in api response
        ["html_report","console_output_file_name","kaya_command","kaya_report_file_name","pid","last_check_time","console_output","git_log"].each{|field| data.delete(field)}
        data
      end

      # Returns the string of custom params values
      # @return [String] foo=bar john=doe
      def custom_params_values
        "kaya_custom_params='#{validate_params(@custom_params).to_json}'".gsub(',', ', ')
      end


      # Returns a hash with valid parameters. This is to prevent command line command with could cause problems
      # @param [hash] custom params
      # @return [hash] validated custom params
      def validate_params custom_params={}
        unless custom_params.nil?
          validated = custom_params.select do |key, value|
            unless value.nil?
              Kaya::Support::Risk.secure? value
            end
          end
        end
        validated || {}
      end

      def add_execution_data key, value
        @execution_data.store(key, value)
        self.save!
      end

      # @param [Hash] details
      # details = {
      #   "name" => scenario.name,
      #   "status" => self.get_status(scenario),
      #   "location" => "#{scenario.location.file}:#{scenario.location.line}"}
      def add_test_result details
        return false unless @results_details.keys.include? details["status"]
        begin
          self.send("@results_details[#{details['status']}]<<#{details}") and self.save!
          true
        rescue
          false
        end
      end

      def add_scenario_result details
        self.add_test_result details
      end

      def task_id
        @task["id"]
      end

      def task_name
        @task["name"]
      end

      def task_type
        @task["type"]
      end

      def is_cucumber?
        @task["cucumber"]
      end

      def is_ruby_platform?
        @task["platform"]
      end

      def generate_cucumber_report?
        @task["cucumber_report"]
      end

      def finish!
        @finished_at= now_in_seconds
        @status = @summary = "finished"
        save_report
        self.save!
        delete_asociated_files!
        $K_LOG.debug "[#{@id}] Executuion finished" if $K_LOG
        true
      end

      def finished_by_timeout!

        @timeout = "#{Kaya::Support::Configuration.execution_time_to_live}"
        reset!("Timeout reached '#{@timeout}'")
        # save_report
        # save_report_summary_and_status!
        $K_LOG.debug "[#{@id}] Finished by timeout (#{Kaya::Support::Configuration.execution_time_to_live} sec)" if $K_LOG
        Kaya::Workers::EmailSender.perform_async(self.id)
        true
      end

      def create_output_dir
        Dir.mkdir "#{Dir.pwd}/kaya/out/#{@id}"
      end

###############################################

      # def check_progress!
      #   if is_running?
      #     collect_console_output!
      #     if reached_timeout?
      #       finished_by_timeout!
      #     elsif is_process_dead?
      #       finish!
      #     end
      #   else
      #     collect_console_output!
      #   end
      # end

      def check_if_finished!
        if is_running?
          if reached_timeout?
            finished_by_timeout!
          elsif is_process_dead?
            finish!
          end
        else
          ensure_finished!
        end
      end

      def ensure_finished!
        finish! unless finished?
      end

      def reached_timeout?
        self.seconds_without_changes > Kaya::Support::Configuration.execution_time_to_live
      end

      def is_process_dead?
        Kaya::Support::Processes.alive? @pid
      end


      def save_report_summary_and_status!
        if is_cucumber?
          self.save_report
          self.get_summary!
          self.get_status!
        end
      end


      # Reads, copy html report from cucumber output file and saves it on a instance variable
      # Persists changes on mongo and then deletes the html reporte file
      def save_report
        if is_cucumber? and is_there_a_report_file?
          new_content = Kaya::View::Parser.adapt_to_kaya(read_report, self)
          if new_content.size > @html_report.size
            @html_report= new_content
            $K_LOG.debug "[#{@id}] Report saved" if $K_LOG
          end
        end
      end

      def is_there_a_report_file?
        begin
          !open_report_file.nil?
        rescue
          false
        end
      end

      def has_report?
        !@html_report.empty?
      end

      def get_summary!
        if is_cucumber?
          report = if is_there_a_report_file?
            read_report
          else
            @html_report
          end
          @summary = Kaya::View::Parser.extract_summary(report) unless summary?
          self.save!
        else

        end
      end

      def summary?
        !(["Not available yet", "running"].include? @summary)
      end

      # Returns the html report file created by KAYA
      # @param [String] html report file name
      # @return [String] html code read from report
      def read_report
        begin
          content = ''
          open_report_file.each_line do |line|
            content+= line
          end
        rescue; end
        content
      end

      def open_report_file
        begin
          FileUtils.cp("#{Dir.pwd}/kaya/temp/#{kaya_report_file_name}", "#{Dir.pwd}/kaya/temp/#{kaya_report_file_name}~")
          file_content = File.open "#{Dir.pwd}/kaya/temp/#{kaya_report_file_name}~", "r"

          File.delete("#{Dir.pwd}/kaya/temp/#{kaya_report_file_name}~")

        rescue
          false
        end
        file_content
      end

      def running!
        @status = "running"
        $K_LOG.debug "[#{@id}] Setted as running" if $K_LOG
        self.save!
      end

      def running?
        @status == "running"
      end

      # tries to get status
      def get_status!
        if is_cucumber?

          value = Kaya::View::Parser.get_status(read_report) if is_there_a_report_file?

          @status = @show_as = value if value
        end
      end

      def is_there_new_lines_to_save? text
        text.size > @console_output.size
      end

      def console_output_file_text
        text = ""
        console_output_content.each_line do |line|
          text += line + "\n"
        end
        text
      end

      def is_there_console_output_file?
        File.exist? "#{Dir.pwd}/kaya/temp/#{console_output_file_name}"
      end

      def console_output_content
        begin
          FileUtils.cp("#{Dir.pwd}/kaya/temp/#{console_output_file_name}", "#{Dir.pwd}/kaya/temp/#{console_output_file_name}~")
          file_content = File.open "#{Dir.pwd}/kaya/temp/#{console_output_file_name}~", "r"
          File.delete("#{Dir.pwd}/kaya/temp/#{console_output_file_name}~")
        rescue Errno::ENOENT
          false
        end
        file_content
      end

      # # Append text to console output
      # # @param [String] text = the text to be appended
      # def append_to_console_output text
      #   @console_output += text
      #   mark_last_check_time
      #   self.save!
      # end

      def mark_last_check_time
        @last_check_time = now_in_seconds
      end

      def update_console_output output
        if output.size > @console_output.size
          @console_output = output
          mark_last_check_time
          self.save!
        else
          raise ExecutionTimeoutError.new("Execution Timeout reached") if (now_in_seconds - @last_check_time) > Kaya::Support::Configuration.execution_time_to_live
        end
      end

      def ensure_complete_console_output output
        if output.size > @console_output.size
          @console_output = output
          self.save!
        end
      end


      # def finished!
      #   @finished_at= now_in_seconds
      #   @status = "finished"
      #   #save_report
      #   #get_summary!
      #   @summary = @status if @summary == "running"
      #   $K_LOG.debug "[#{@id}] Executuion finished" if $K_LOG
      #   self.save!
      #   begin
      #     $NOTIF.execution_finished self
      #   rescue => e
      #     $K_LOG.error "Error at notifying #{e}"
      #   end
      #   @summary
      # end


      def append_output output
        @console_output += output
        mark_last_check_time
        self.save!
      end

      def is_running?
        @status =~ /running|stated/i
      end


      def started?
        @status == "started"
      end

      def finished?
        @status =~ /(finished|stopped)/i
      end

      def process_finished?
        ! process_running?
      end

      def process_running?
        Kaya::Support::Processes.process_running? pid
      end

      def is_finished?; self.finished?; end

      def report_says_finished?
        Kaya::View::Parser.finished_statement? @html_report
      end

      def stopped?
        @status =~ /(reset|stopped)/i
      end

      def reset! reason=nil
        status_text = "stopped"
        status_text += " (#{reason})" if reason
        @status = @summary = status_text
        @finished_at= now_in_seconds
        save_report
        delete_asociated_files!
        self.save!
        $K_LOG.debug "[#{@id}] Execution stoppped (reset)" if $K_LOG
      end

      def has_summary?
        report_has_summary?
      end

      def report_has_summary?
        @summary.include? "scenario"
      end

      def has_scenario_executed?
        Kaya::View::Parser.has_scenarios_executed? @html_report
      end

      def mark_as_saw!
        @saw = true
        $K_LOG.debug "[#{@id}] Marked as saw" if $K_LOG
        self.save!
      end

      def delete_console_output_file!
        begin
          File.delete("#{Dir.pwd}/kaya/temp/#{console_output_file_name}")
          $K_LOG.debug "[#{@id}] Console output files deleted" if $K_LOG
          true
        rescue => e
          false
        end
      end

      def delete_kaya_report_file!
        begin
          File.delete("#{Dir.pwd}/kaya/temp/#{kaya_report_file_name}")
          $K_LOG.debug "[#{@id}] Report files deleted" if $K_LOG
          true
        rescue => e
          false
        end
      end

      def delete_copy_kaya_report_file!
        begin
          File.delete("#{Dir.pwd}/kaya/temp/#{kaya_report_file_name}~")
          true
        rescue => e
          false
        end
      end

      def delete_asociated_files!
        delete_console_output_file!
        delete_kaya_report_file!
        delete_copy_kaya_report_file!
      end

      # Returns the seconds that there is no console output changes only if it is not finished, else returns 0
      # This is aimed to help to detect if execution is freezed (or has a debugger statement)
      def seconds_without_changes
        (self.finished? or self.stopped?) ? 0 : (now_in_seconds - @last_check_time)
      end

      def elapsed_time
        (finished_at || now_in_seconds) - started_at
      end

      # Returns actal timestamp
      # @return [Time]
      def now
        Time.now.localtime
      end

      # Returns the started at time attribute in a format way (configured on kaya info)
      # @return [String]
      def started_at_formatted
        Kaya::Support::TimeHelper.formatted_time_for @started_at
      end

      # Returns the finished at time attribute in a format way (configured on kaya info)
      # @return [String]
      def finished_at_formatted
        Kaya::Support::TimeHelper.formatted_time_for @finished_at
      end

      # Returns the timestamp in seconds
      # @param [Fixnum] timestamp
      def now_in_seconds
        now.to_i
      end

      # Persists the status of the object on mongo.
      # If result exist update it, else creates it
      # @return [Boolean] operation result
      def save!
        Kaya::Database::MongoConnector.result_data_for_id(id) ? Kaya::Database::MongoConnector.update_result(result_data_structure) : Kaya::Database::MongoConnector.insert_result(result_data_structure)
        $K_LOG.debug "[#{@id}] Result saved" if $K_LOG
      end

    end
  end
end