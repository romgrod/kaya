module Kaya
  module Commands
    def self.install origin=nil

      begin


        TaskRack.start([])

        puts "

        A new folder called kaya was created. Check the configuration file with the name kaya_conf.
        You'll find some configuration values there. Take a look and set your preferences!
        Enjoy Kaya
        Thanks
        "

        puts "You don't have defined a cucumber.yml file. YOU SHOULD TO USE KAYA :)" if Kaya::Tasks.cucumber_yml.empty?
        puts "Now, you can run bundle install and then `kaya start` command"

      rescue => e
        puts "\n\nERROR: #{e}\n\n #{e.backtrace}"

      end
    end
  end
end