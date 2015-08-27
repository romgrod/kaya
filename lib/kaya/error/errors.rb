module Kaya
  module Error
    # Raised when there is an error related to Tasks.
    class Task < StandardError
      attr_reader :task_name

      def initialize(task_name, message=nil)
        @task_name = task_name
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

    class ExecutionTimeoutError < StandardError
      attr_reader :id, :message

      def initialize(id, message=nil)
        @id = id
        @message = message
        super message

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

    class TaskNotFound < StandardError
      def initialize(message=nil)
        message ="Task not foun" if message.nil?
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