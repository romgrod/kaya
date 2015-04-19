require 'kaya'

module Kaya
  module Workers
    class GarbageCleaner

      # This worker delete all zombies files
      include Sidekiq::Worker
        def perform

          Kaya::Support::Configuration.get
          Kaya::Database::MongoConnector.new(Kaya::Support::Configuration.db_connection_data)

          get_present_output_files = Dir["#{Dir.pwd}/kaya/temp/*.out"].select{|file|  file.start_with? "kaya_co_"}
          get_present_report_files = Dir["#{Dir.pwd}/kaya/temp/*.html"].select{|file|  file.start_with? "kaya_report_"}

          get_present_output_files.each do |output_file|
            if result = Kaya::Results::Result.get(output_file.scan(/\d+/).first)
              File.delete("#{Dir.pwd}/kaya/temp/#{output_file}") if result.finished?
            end
          end

          get_present_report_files.each do |report_file|
            if result = Kaya::Results::Result.get(report_file.scan(/\d+/).first)
              File.delete("#{Dir.pwd}/kaya/temp/#{report_file}") if result.finished?
            end
          end
        end
    end
  end
end
