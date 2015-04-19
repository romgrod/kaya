  require 'yaml'

require 'tempfile'


module Kaya
  module Cucumber
    class Task

      def self.run result

        result.kaya_report_file_name= "kaya_report_#{result.id}.html"

        begin
          File.delete("#{Dir.pwd}/Gemfile.lock")
        rescue
        end

        bundle_output = Kaya::Support::Console.execute "bundle install"
        $K_LOG.debug "[result:#{result.id}] Bundle install performed" if $K_LOG

        result.save_to_bundle_output bundle_output

        unless bundle_output.include? "Could not find"

          # Adding _id=result.id to use inside execution the posiibility to add information to the result
          result.kaya_command= "#{Kaya::Support::Configuration.headless?} bundle exec cucumber #{result.command} -f pretty -f html -o kaya/temp/#{result.kaya_report_file_name} #{result.custom_params_values} _id=#{result.id} "

          result.console_output_file_name= "kaya_co_#{result.id}.out"

          result.save!

          command = "#{result.kaya_command} 2>&1 | tee -a kaya/temp/#{result.console_output_file_name}"

          $K_LOG.debug "[result:#{result.id}] Running in headless mode" if $K_LOG and Kaya::Support::Configuration.headless?

          Dir.mkdir "#{Dir.pwd}/kaya/temp" unless Dir.exist? "#{Dir.pwd}/kaya/temp"


          $K_LOG.debug "[result:#{result.id}] Creating process" if $K_LOG
          result.pid= Kaya::Support::Processes.fork_this command
          $K_LOG.debug "[result:#{result.id}] Process (#{result.pid}) exec'in" if $K_LOG

          $K_LOG.debug "[result:#{result.id}] Running saved command}" if $K_LOG

          result.running!

          $K_LOG.debug "[result:#{result.id}] Result setted as running" if $K_LOG

          result.append_result_to_console_output!

          result.save_report!

          result.save!

          result.append_result_to_console_output!

        end # unless

      end # end self.run

    end #end Task class
  end # enc Cucumber module
end