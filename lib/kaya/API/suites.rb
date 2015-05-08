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
          Kaya::Suites.running_suites
        else
          response["request"] = options[:active] ? "Active Suites" : "Suites"
          Kaya::Suites.suites options[:active]
        end


        if suites.size.zero?
          response["message"] = options[:running] ? "Running suites not found" : "Suites not found"
        else
          # Gets the executions for given ip
          suites = suites.map do |suite|
            results_for_suite = Kaya::Results.results_ids_for suite["_id"]
            suite["results"]={
              "size" => results_for_suite.size,
              "ids" => results_for_suite
            }
            suite
          end

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
