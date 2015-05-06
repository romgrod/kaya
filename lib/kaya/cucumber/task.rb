  # require 'yaml'

require 'tempfile'


module Kaya
  module Cucumber
    class Task

      def self.run result

        Kaya::Workers::ExecutionPerformer.perform_async(result.id)

     end # end self.run

    end #end Task class
  end # enc Cucumber module
end