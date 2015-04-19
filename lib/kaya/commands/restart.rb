module Kaya
  module Commands
    def self.restart
      $K_LOG.debug "#{self}:#{__method__}" if $K_LOG
      self.stop
      self.start
    end
  end
end