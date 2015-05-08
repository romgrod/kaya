module Kaya
  module Commands
    def self.start nodemon=false


      $K_LOG.debug "Starting Kaya" if $K_LOG
      begin

        Kaya::Support::Configuration.new

        $K_LOG.debug "Starting...\n\n#{Kaya::Support::Logo.logo}" if $K_LOG

        $K_LOG.debug "Checking config.ru file existance" if $K_LOG
        raise "ERROR --- kaya/config.ru file was not found. Try with `kaya prepare` command before `kaya start`" unless File.exist?("#{Dir.pwd}/kaya/config.ru")

        $K_LOG.debug "Checking unicorn.rb file existance" if $K_LOG
        raise "ERROR --- kaya/unicorn.rb file was not found. Try with `kaya prepare` command before `kaya start`" unless File.exist?("#{Dir.pwd}/kaya/unicorn.rb")

        Kaya::Support::Logo.show


        Kaya::Support::Configuration.show_configuration_values


        $K_LOG.debug "Connecting to database" if $K_LOG
        Kaya::Database::MongoConnector.new(Kaya::Support::Configuration.db_connection_data)


        $K_LOG.debug "Loading doc" if $K_LOG
        Kaya::Support::Documentation.load_documentation

        if Kaya::Support::Configuration.headless?
          $K_LOG.debug "Headless mode: ON - Checking xvfb existance" if $K_LOG
          res = Kaya::Support::Console.execute "xvfb-run"
          if res.include? "sudo apt-get install xvfb"
            puts "
You have configured headless mode but xvfb package is not installed on your system.
Please, install xvfb package if you want to run browsers in headless mode
or set HEADLESS active value as false if you do not use browser in your tests."
            return
          end
        end

        puts "\n"
        $K_LOG.debug "Cleanning old kaya report files" if $K_LOG
        Kaya::Support::FilesCleanner.delete_kaya_reports()
        $K_LOG.debug "Old kaya report files cleanned" if $K_LOG


        $K_LOG.debug "Cleanning old kaya console files" if $K_LOG
        Kaya::Support::FilesCleanner.delete_console_outputs_files()
        $K_LOG.debug "Old kaya console files cleanned" if $K_LOG

        $K_LOG.debug "Clearing kaya log file" if $K_LOG
        Kaya::Support::FilesCleanner.clear_kaya_log
        $K_LOG.debug "Kaya log file cleanned" if $K_LOG


        $K_LOG.debug "Clearing sidekiq log file" if $K_LOG
        Kaya::Support::FilesCleanner.clear_sidekiq_log
        $K_LOG.debug "Sidekiq log file cleanned" if $K_LOG

        # To prevent showing suites as runnnig when service started recently reset all suites
        $K_LOG.debug "Reseting suites statuses" if $K_LOG
        Kaya::Suites.reset_statuses
        $K_LOG.debug "Suites statuses reseted" if $K_LOG
        puts "\n* Suites Status: Reseted"

        # Force results to reset or finished status
        $K_LOG.debug "Reseting defunct executions" if $K_LOG
        Kaya::Results.reset_defuncts
        $K_LOG.debug "Defunct execution reseted" if $K_LOG
        puts "\n* Results: Reseted".green

        kaya_arg = "-D" unless nodemon

        $K_LOG.debug "Starting Sidekiq" if $K_LOG
        Kaya::BackgroundJobs::Sidekiq.start
        $K_LOG.debug "Sidekiq Started" if $K_LOG

        # Start kaya app
        $K_LOG.debug "Starting Kaya" if $K_LOG
        Kaya::Support::Console.execute "unicorn -c #{Dir.pwd}/kaya/unicorn.rb -p #{Kaya::Support::Configuration.port} #{kaya_arg} kaya/config.ru"

        $K_LOG.debug "Kaya started" if $K_LOG

        # Save all kaya pids
        $K_LOG.debug "Saving PIDs for Kaya" if $K_LOG
        File.open("#{Dir.pwd}/kaya/kaya_pids", "a"){ |f| f.write Kaya::Support::Processes.kaya_pids.join("\n")}
        $K_LOG.debug "Kaya PIDs saved" if $K_LOG

        puts "\n\n* Kaya is succesfully Started!\n".green
        if $IP_ADDRESS
            puts "\n\n You can go now to http://#{$IP_ADDRESS}:#{Kaya::Support::Configuration.port}/kaya\n\n"
            $K_LOG.debug "You can go now to http://#{$IP_ADDRESS}:#{Kaya::Support::Configuration.port}/kaya" if $K_LOG
        end

      rescue => e
        $K_LOG.error "Error starting Kaya: #{e}#{e.backtrace}" if $K_LOG
        puts "An error ocurred while starting Kaya. See kaya log for more information.#{e} #{e.backtrace}".red
      end
    end
  end
end