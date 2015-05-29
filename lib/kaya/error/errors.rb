module Kaya
  module Error
    # Raised when there is an error related to Suites.
    class Suite < StandardError
      attr_reader :suite_name

      def initialize(suite_name, message=nil)
        @suite_name = suite_name
        message = message
        super(message)
      end
    end

    # Raised when there is an error related to Results.
    class Result < StandardError
      attr_reader :id

      def initialize(id, message=nil)
        @id = id
        message = message
        super(message)
      end

    end

    class KayaFile < StandardError
      def initialize file_path
        super("Could not find '#{file_path} file" )
      end
    end

    class KayaDir < StandardError
      def initialize file_path
        super("Could not find '#{file_path}' dir")
      end
    end

    class SuiteNotFound < StandardError
      def initialize(message=nil)
        message ="Suite not foun" if message.nil?
        super(message)
      end
    end

    # Raised when there is an error related to Help.
    class Help < StandardError
       def initialize(message=nil)
        message = message
        super(message)
      end
    end
  end
end