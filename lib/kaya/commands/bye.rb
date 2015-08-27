module Kaya
  module Commands
    def self.bye
        $K_LOG.debug "#{self}:#{__method__}" if $K_LOG
        self.stop
        Kaya::Support::FilesCleanner.delete_kaya_folder
        puts "Files cleanned"
        puts "Bye!..."
    end
  end
end