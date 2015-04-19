module Kaya
  module Support
    class ErrorHandlerHelper

      def self.evaluate exception
        case exception
          when Mongo::ConnectionTimeoutError
            ["Timeout Error","Could not connect to database"]
          when Psych::SyntaxError
            ["Parse Error","Cucumber.yml file is not configured correctly (#{exception.message})"]
          when Kaya::Error::Suite
            ["Suite Name Error",exception.message]
          when Kaya::Error::CucumberYML
            ["No Cucumber file", exception.message]
          else
            message = "#{exception.message}#{exception.backtrace}"
            ["Unknown Error", message]
        end
      end
    end
  end
end


