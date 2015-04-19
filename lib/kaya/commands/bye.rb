module Kaya
  module Commands
    def self.bye
        $K_LOG.debug "#{self}:#{__method__}" if $K_LOG
        self.stop
        FilesCleanner.delete_kaya_folder
        puts "Files cleanned"
        puts "She is gone!"

    end
  end
end