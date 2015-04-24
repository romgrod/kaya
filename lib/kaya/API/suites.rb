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
          start = Time.now.to_f
          response["suites"] = suites.map{|suite_id| Kaya::Suites::Suite.get(suite_id).api_response}
          $K_LOG.debug "#{suites.size} retrieved in (#{Time.now.to_f - start} s)" if $K_LOG

          response["size"] = suites.size
        end
        response
      end
    end
  end
end
