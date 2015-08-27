require 'kaya'
require 'socket'

module Kaya
  module Workers
    class Executor
      include Sidekiq::Worker

      sidekiq_options :retry => false

        def perform(result_id)

          @output = ""

          Kaya::Support::Configuration.get
          Kaya::Database::MongoConnector.new Kaya::Support::Configuration.db_connection_data

          Kaya::Support::ChangeInspector.is_there_a_change?

          result = Kaya::Results::Result.get(result_id)

          result.kaya_report_file_name= "kaya_report_#{result_id}.html"

          if result.is_ruby_platform?
            if Kaya::Platforms::Ruby.using_bundler?
              bundle_output = Kaya::Support::Console.execute "bundle install"
            end
            if bundle_output
              result.append_output bundle_output
              if bundle_output.include? "Could not find"
                result.finish!
                raise "An error ocurred installing gem while executing bundler"
              end
            end
          end

          Dir.mkdir "#{Dir.pwd}/kaya/temp" unless Dir.exist? "#{Dir.pwd}/kaya/temp"
          cucumber_report_command = result.is_cucumber? ? "-f pretty -f html -o kaya/temp/#{result.kaya_report_file_name}" : ""

          # Adding _id=result.id to use inside execution the posiibility to add information to the result
          result.kaya_command= "#{Kaya::Support::Configuration.headless?} #{result.command} #{cucumber_report_command} #{result.custom_params_values} _id=#{result.id} "

          $K_LOG.debug "[result:#{result.id}] Creating process" if $K_LOG

          result.running!

          $K_LOG.debug "[result:#{result.id}] setted as running" if $K_LOG

          @output = ""

          #################
          # POPEN3 tuto
          #
          # http://blog.honeybadger.io/capturing-stdout-stderr-from-shell-commands-via-ruby/?utm_source=rubyweekly&utm_medium=email
          #
          #
          ##################
          @count = 0
          IO.popen("#{result.kaya_command}") do |data|
            result.pid ="#{`ps -fea | grep #{Process.pid} | grep -v grep | awk '$2!=#{Process.pid} && $8!~/awk/ && $3==#{Process.pid}{print $2}'`}"
            result.save!
            while line = data.gets
              @count += 1
              @output += line
              if @count == 10
                result.append_output @output
                @output = ""
                @count = 0
              end
              if result.seconds_without_changes > Kaya::Support::Configuration.execution_time_to_live
                result.finished_by_timeout! and break
              end
            end
            result.append_output @output unless @output.empty?
          end

          result.ensure_finished!

          $K_LOG.debug "[result:#{result.id}]| command => #{result.kaya_command} | result as => #{result.status}" if $K_LOG

        end
    end
  end
end
