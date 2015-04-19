module Kaya
  module Support
    module Logs

      def self.path
        "#{Dir.pwd}/kaya/"
      end

      def self.all
        logs = Hash.new
        Dir.glob(path + '*_log') do |log_file|
          name = log_file.split("/").last.gsub('.log','')
          text = File.read(log_file)
          logs[name] = text
        end
        logs
      end

      def self.read_log_file_content_for log=nil
          path = "#{Dir.pwd}/kaya/#{log}"
          if File.exist?("#{path}")
            FileUtils.cp(path, "#{path}~")
            all_content = IO.read("#{path}~")
            content = if all_content.split("\n").size > 500
               all_content.split("\n")[-500..-1].join("<br>")
            else
              all_content.gsub("\n","<br>")
            end
            File.delete("#{path}~")
          else
            content = ""
          end
          content
      end
    end
  end
end