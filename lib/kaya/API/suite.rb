module Kaya
  module API

    class Suite

      def self.info(suite_id)
        suite_id = suite_id.to_i if suite_id.respond_to? :to_i
        response = {
          "project_name" => Dir.pwd.split("/").last,
          "suite" => nil,
          "message" => nil
        }
        suite = Kaya::Suites::Suite.get(suite_id)
        $K_LOG.debug "SUITE => #{suite}"
        if suite.nil?
          response["message"] = "Suite not found"
        else
          response["suite"] = suite.api_response
        end
        response
      end

      def self.info_for_name suite_name
        $K_LOG.debug "suite_name received on info_for_name #{suite_name}"
        suite_id = Kaya::Suites.suite_id_for(suite_name)
        $K_LOG.debug "suite_id obtained on 'Kaya::Suites.suite_id_for' #{suite_id}"
        self.info(suite_id)
      end


      def self.status suite_id
        response = info(suite_id)

        output = if response["message"]
          {
            "suite_id" => nil,
            "message" => response["message"]
          }
        else
          {
            "suite_id" => response["suite"]["_id"],
            "status" => response["suite"]["status"]
          }
        end
        output
      end
    end
  end
end

