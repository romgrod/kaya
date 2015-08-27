module Kaya
  module Commands
    def self.install origin=nil

      begin


        Kaya::TaskRack.start([])

        puts "

        A new folder called kaya was created. Check the configuration file under config/ folder with the name kaya.conf.
        You'll find some configuration values there. Take a look and set your preferences!
        Enjoy Kaya
        Thanks
        "
        puts "Now, you can run bundle install and then `kaya start` command"

      rescue => e
        puts "\n\nERROR: #{e}\n\n #{e.backtrace}"

      end
    end
  end
end