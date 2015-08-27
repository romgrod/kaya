module Kaya
  module Support
    module Console

      # Executes system command
      def self.execute command
        `#{command}`
        # res = IO.popen("#{command}")
        # res.readlines.join
      end
    end
  end
end