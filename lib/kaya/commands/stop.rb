module Kaya
  module Commands
    def self.stop

      $K_LOG.debug "#{self}:#{__method__}" if $K_LOG

      Kaya::Support::Configuration.get

      # Get pids from saved file on start process
      if File.exist? "#{Dir.pwd}/kaya/kaya_pids"

        kaya_pids = IO.read("#{Dir.pwd}/kaya/kaya_pids").split("\n")
        # Kill all pids specified on file

        begin
          Kaya::Support::Processes.kill_all_these kaya_pids
        rescue
        end

        # Delete pid file
        File.delete("#{Dir.pwd}/kaya/kaya_pids")
      end

      if File.exist? "#{Dir.pwd}/kaya/sidekiq_pid"

        sidekiq_pid = IO.read("#{Dir.pwd}/kaya/sidekiq_pid").split("\n")

        begin
          Kaya::Support::Processes.kill_all_these sidekiq_pid
        rescue
        end


        File.delete("#{Dir.pwd}/kaya/sidekiq_pid")
      end

      # Evaluates if any pid could not be killed (retry)
      Kaya::Support::Processes.kill_all_these(Kaya::Support::Processes.kaya_pids)

      if Kaya::Support::Processes.kaya_pids.empty?

        puts "
Kaya stopped!"

      else
        puts "
Could not stop Kaya.
If Kaya is still running please type `kaya help` to get some help"
      end
    end
  end
end

