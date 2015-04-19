module Kaya
  module Cucumber
    module Features

      # Returns an array of all feature files paths (only feature files)
      # @return [Array]
      def self.feature_files_names
        Dir['**/*.*'].select do |file_path_name|
          file_path_name.start_with? "features/" and file_path_name.end_with? ".feature"
        end
      end

    end
  end
end