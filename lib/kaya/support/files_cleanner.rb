require 'fileutils'

module Kaya
  module Support
    class FilesCleanner

      # Delete all kaya_reports html files
      def self.start!
        begin
          self.delete_kaya_reports_dir
        rescue
          false
        end

      end

      def self.delete_file file_name
        begin
          File.delete("#{file_name}") and true
        rescue
          false
        end
      end

      def self.delete_kaya_reports_dir
        location = "#{Dir.pwd}/kaya/kaya_reports"
        FileUtils.rm_rf(location)
        Dir.mkdir(location)
      end

      def self.delete_report_which_has text
        text = text.to_s if text.respond_to? :to_s
        report = all_kaya_reports.select do |file|
          file.include? text
        end.first

        delete_file(report)
      end

      def self.delete_html_report_for result_id
        file = all_kaya_reports.select do |file|
          file.include? result_id
        end.first
        delete_file(file) if file
      end

      def self.all_kaya_reports
        Dir["#{Dir.pwd}/kaya/temp/*.*"].select do |file|
          !file.scan(/kaya_report_\d+\.html/).empty?
        end
      end

      # Deletes all kaya html reports
      def self.delete_kaya_reports
        # Get all html report files
        (Kaya::Support::Git.reset_hard and Kaya::Support::Git.pull) if Kaya::Support::Configuration.use_git?
        begin
          self.delete_all_kaya_reports
        rescue
          false
        end
      end

      # Deletes all kaya html reports files
      # @return [Boolean] if has deleted reports
      def self.delete_all_kaya_reports
        not all_kaya_reports.each do |file|
          self.delete_file(file)
        end.empty?

      end

      # Deletes kaya execution output files
      # @return [Boolean] for success
      def self.delete_console_outputs_files
        (Kaya::Support::Git.reset_hard and Kaya::Support::Git.pull) if Kaya::Support::Configuration.use_git?
        begin
          self.delete_all_console_output_files
          true
        rescue
          false
        end
      end

      # Deletes all kaya execution output files
      # @return [Boolean] if has deleted files
      def self.delete_all_console_output_files
        not all_console_output_reports.each do |file|
          delete_file(file)
        end.empty?
      end

      def self.all_console_output_reports
        Dir["#{Dir.pwd}/kaya/temp/*.*"].select do |file|
          !file.scan(/kaya_co_\d+\.out/).empty?
        end
      end

      def self.delete_console_output_for result_id
        file=all_console_output_reports.select do |file|
          file.include? result_id
        end.first
        delete_file(file) if file
      end

      def self.clear_sidekiq_log
        sidekiq_file_path = "#{Dir.pwd}/kaya/sidekiq_log"
        if File.exist? sidekiq_file_path
          File.delete(sidekiq_file_path)
          File.open(sidekiq_file_path, "a+"){}
        end
      end

      def self.clear_kaya_log
        kaya_log_file_path = "#{Dir.pwd}/kaya/kaya_log"
        if File.exist? kaya_log_file_path
          File.delete(kaya_log_file_path)
          File.open(kaya_log_file_path, "a+"){}
        end
      end

      # Deletes kaya folder. Used by 'bye command'
      # @return [Boolean] for success
      def self.delete_kaya_folder
        begin
          location = "#{Dir.pwd}/kaya"
          FileUtils.rm_rf(location)
          true
        rescue
          false
        end
      end

    end
  end
end