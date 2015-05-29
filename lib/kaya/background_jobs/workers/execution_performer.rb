require 'kaya'

module Kaya
  module Workers
    class ExecutionPerformer
      include Sidekiq::Worker
        def perform(result_id)

          puts result_id

          Kaya::Support::Configuration.get
          Kaya::Database::MongoConnector.new Kaya::Support::Configuration.db_connection_data

          result = Kaya::Results::Result.get(result_id)

          p result

          result.kaya_report_file_name= "kaya_report_#{result_id}.html"

          begin
            File.delete("#{Dir.pwd}/Gemfile.lock")
          rescue
          end

          if !Kaya::Support::ChangeInspector.is_there_gemfile_lock?
            bundle_output = Kaya::Support::Console.execute "bundle install"
            $K_LOG.debug "[result:#{result.id}] Bundle install performed" if $K_LOG
          elsif Kaya::Support::ChangeInspector.is_there_a_change?
            bundle_output = Kaya::Support::Console.execute "bundle update"
            $K_LOG.debug "[result:#{result.id}] Bundle update performed" if $K_LOG
          end
          if bundle_output
            result.save_to_bundle_output bundle_output
            raise "An error ocurred installing gem" if bundle_output.include? "Could not find"
          end

          # Adding _id=result.id to use inside execution the posiibility to add information to the result
          result.kaya_command= "#{Kaya::Support::Configuration.headless?} cucumber #{result.command} -f pretty -f html -o kaya/temp/#{result.kaya_report_file_name} #{result.custom_params_values} _id=#{result.id} "

          result.console_output_file_name= "kaya_co_#{result.id}.out"

          result.save!

          command = "#{result.kaya_command} 2>&1 | tee -a kaya/temp/#{result.console_output_file_name}"

          $K_LOG.debug "[result:#{result.id}] Running in headless mode" if $K_LOG and Kaya::Support::Configuration.headless?

          Dir.mkdir "#{Dir.pwd}/kaya/temp" unless Dir.exist? "#{Dir.pwd}/kaya/temp"

          $K_LOG.debug "[result:#{result.id}] Creating process" if $K_LOG
          result.pid= Kaya::Support::Processes.fork_this command
          result.running!
          result.save!
          $K_LOG.debug "[result:#{result.id}] Process => #{result.pid}(PID) | command => saved | result as => running" if $K_LOG

          # suite = Kaya::Suites::Suite.get(result.suite_id)
          begin
            result.check_finished!
            sleep 2
          end while not result.is_finished?

        end
    end
  end
end
