module Kaya
  module Support
    module Console

      # Executes system command
      def self.execute command
        `#{command}`
      end
    end
  end
end