module Kaya
  module Support
    module Clean
      def self.start
        Kaya::Tasks.reset_statuses
        Kaya::Results.reset_defuncts
        Kaya::Support::FilesCleanner.delete_all_kaya_reports
        Kaya::Support::FilesCleanner.delete_all_console_output_files
      end
    end
  end
end