module Kaya
  module API
    module Suites

      # @param [hash] options = {:running, :active}
      def self.list(options ={})

        response = {
          "project_name" => Dir.pwd.split("/").last,
          "size" => 0,
          "suites" => [],
          "message" => nil
        }
        suites = if options[:running]
          response["request"] = "Running Suites"
          Kaya::Suites.all_running_suites
        else
          response["request"] = options[:active] ? "Active Suites" : "Suites"
          Kaya::Suites.suite_ids options[:active]
        end


        if suites.size.zero?
          response["message"] = options[:running] ? "No running suites found" : "No suites found"
        else
          suites.each do |suite_id|
            suite = Kaya::Suites::Suite.get(suite_id)
            response["suites"] << suite.api_response
          end
          response["size"] = suites.size
        end
        response
      end
    end
  end
end
