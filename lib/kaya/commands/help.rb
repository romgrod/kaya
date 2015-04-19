module Kaya
  module Commands
    def self.help
      $K_LOG.debug "#{self}:#{__method__}" if $K_LOG
      puts "
If you shutdown kaya and then you want to get it up and the port you are using is already in use you could use the following commands (Ubunutu OS):

  $sudo netstat -tapen | grep :8080

In this example we use the port 8080. This command will give you the app that is using the port. Then you could kill it getting its PID previously."
    end
  end
end