module Kaya
  module Support
    class Processes
      def self.kill_by_result_id(result_id)

        pid = pid_for(result_id)

        return false if pid.nil?

        childs = process_childs(pid)

        unless pid.zero?
          begin
            childs.each{|ch_pid| kill_p(ch_pid)} unless childs.empty?
            kill_p(pid)
            true # Process killed
          rescue Errno::EPERM # Denied permission to kill process
            begin
              kill_dash_nine(pid) and true # Process killed
            rescue
              false
            end
          rescue Errno::ESRCH # Process did not exist
            false
          end
        else
            puts "Cannot find process id"
        end
      end

      def self.kill_p(pid)
        pid = pid.to_i if pid.respond_to? :to_i
        Process.kill('INT', pid)
      end

      def self.kill_dash_nine(pid)
        pid = pid.to_i if pid.respond_to? :to_i
        puts "kill -9 #{pid}" if $DEBUG
        Kaya::Support::Console.execute "kill -9 #{pid}"
      end

      def self.pid_for(result_id)
        result = Kaya::Results::Result.get(result_id)
        result.pid.to_i
      end

      def self.process_running? pid
        unless pid.nil?
          res = Kaya::Support::Console.execute("ps -p #{pid}").split("\n").last
          unless res.nil?
            res.include? "#{pid}" and !res.include? "<defunct>"
          end
        end
      end


      #Recibe un PID y devuelve un array con los PID de sus hijos
      def self.process_childs(pid)
        Kaya::Support::Console.execute("ps -fea | grep #{pid} | grep -v grep | awk '$2!=#{pid} && $8!~/awk/ && $3==#{pid}{print $2}'").split("\n")
      end

      def self.kaya_pids
        res = Kaya::Support::Console.execute "ps -fea | grep 'unicorn.rb -p #{Kaya::Support::Configuration.port}'"

        res.split("\n").select{|lines| !lines.include? "grep"}.map{|line| line.split[1]}
      end

      def self.sidekiq_pids
        res = Kaya::Support::Console.execute "ps -fea | grep 'sidekiq'"

        res.split("\n").select{|lines| !lines.include? "grep"}.map{|line| line.split[1]}
      end

      def self.kill_all_these pids=nil
        if pids
          until pids.empty?
            pid = pids.pop
            if process_running? pid
              begin
                kill_dash_nine(pid)
              rescue Errno::ESRCH
                puts "Could not find process id #{pid} to kill"
              end
            end
          end
        end
      end


      def self.fork_this command
        fork{exec("#{command}")}
      end

    end
  end
end