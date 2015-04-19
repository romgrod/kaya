module Kaya
  module View
    class Sections

      @@sections = {
        "Test Suites" => "suites/suites",
        "Features" => "features/features",
        "Feature" => "features/feature",
        "Results"=>  "results/results",
        "Console" => "results/console",
        "Report" => "results/report",
        "All Results"=> "results/all",
        "Repo" => "",
        "Logs" => "logs/log",
        "Help" => ""
      }

      def self.path_for section
        @@sections[section]
      end


    end
  end
end