module Kaya
  module API
    module Suites

      # @param [hash] options = {:running, :active, :ip}
      def self.list(options ={})

        start = Time.now.to_f

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
          # Gets the executions for given ip
          suites = suites.map{|suite_id| Kaya::Suites::Suite.get(suite_id).api_response}

          suites = suites.map do |suite|
            unless Kaya::Results.results_for_suite_id_and_ip(suite["_id"], options[:ip]).empty?
              suite["status"]="RUNNING"
              suite
            else
              suite
            end
          end

          response["suites"] = suites
          $K_LOG.debug "#{suites.size} retrieved in (#{Time.now.to_f - start} s)" if $K_LOG

          response["size"] = suites.size
        end
        response
      end
    end
  end
end
