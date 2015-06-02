module Kaya
  module View
    class Parser

      # Parses cucumber report html doc
      # Divides in each parts of document
      # @param [String] source = the html code
      # @param [Kaya::Result] the result object
      def self.adapt_to_kaya(source, result)
          source.gsub! 'Collapse All</p></div></div></div>',"
            Collapse All</p></div></div></div>
              <div>#{kaya_info(result)}</div>"
        # end
        source.inspect
      end

      # This is the information added to html report
      # @param [Kaya::Results::Result] result object
      # @return [String] the html to be added
      def self.kaya_info(result)
        info  = "<h2><strong>Task:</strong> #{result.task_name}</h2>"
        info += "<h4>Execution name: #{result.execution_name.gsub('-_-',' ')}</h4>" unless result.execution_name.empty?
        info += "<h4>Command: #{result.command}</h4>"
        info += "<h4>Custom Params: #{result.custom_params_values.split('=').last}</h4>"
        info += "<h4>Started: #{result.started_at_formatted}</h4>"
        info += "<h4>Commit ID: #{result.git_log.split('\n').first}</h4>"
        info += "<h4><input type='button' onclick='window.close();' value='Close this window' />"
      end

      def self.extract_summary source
        if no_scenario_but_green?(source) # 0 scenarios executed
          get_elapsed_time_for_zero(source)
        elsif has_scenarios_executed?(source) # scenarios executed > 0
          get_scenarios_summary(source)
        else
          "running"
        end
      end

      # Returns the status present on html cucumber report
      # @param [String] the entire report html code
      # @reurn [String] the text of status
      def self.get_status(source)
         source.scan(/\d\sscenarios?\s\(\d+\s(\w+)/i).flatten.first if finished_statement?(source)
      end

      # Checks if report says that execution is finised
      # @param [String] source = the entire report html code
      # @return [Boolean] true if report says finished
      def self.finished_statement? source
        !(source =~ /Finished in .*s seconds/).nil?
      end

      # Checks if result report is about no scenarios executed (scenarios not found)
      # @param [String] the entire report html source code
      # @return [Boolean] true if is finished (green) and no scenarios executed (It means that is empty. No scenarios executed)
      def self.no_scenario_but_green?(source)
        source.include? '0m0.000s seconds'
      end

      # Checks if has scenario results summary
      # @param [String] the entire report html source code
      # @return [Boolean] true if there is scenarios executed
      def self.has_scenarios_executed? source
        (source.include? "scenario") and (source.scan(/\d+\sscenario.*\)/).size > 0)
      end

      #
      def self.get_elapsed_time_for_zero(source)
        "0 Scenarios " + source.scan(/Finished in <strong>0m0.000s seconds/).first.gsub("<strong>","")
      end

      def self.get_scenarios_summary(source)
        source.scan(/\d+\sscenario.*\)/).first.gsub(/\<.+\>/,' - ')
      end

    end
  end
end