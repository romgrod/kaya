module Kaya
  module Support
    class ErrorHandlerHelper

      def self.evaluate exception
        case exception
          when Mongo::ConnectionTimeoutError
            ["Timeout Error","Could not connect to database"]
          when Psych::SyntaxError
            ["Parse Error","Cucumber.yml file is not configured correctly (#{exception.message})"]
          when Kaya::Error::SuiteNotFound
            ["Suite Name Error",exception.message]
          when Kaya::Error::Result
            ["Result Error", excetion.message]
          when Kaya::Error::KayaFile
            ["Kaya File", exception.message]
          when Kaya::Error::KayaDir
            ["Kaya File", exception.message]
          when Kaya::Error::Help
            ["Help Error", exception.message]
          else
            ["Unknown Error", "#{exception.message}#{exception.backtrace}"]
        end
      end
    end
  end
end


