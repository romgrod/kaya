module Kaya
  module Platforms
    class Ruby
      def self.is_there_gemfile_lock?
        begin
          IO.read("#{Dir.pwd}/Gemfile.lock")
        rescue
          false
        end
      end

      def self.using_gemfile?
        begin
          IO.read("#{Dir.pwd}/Gemfile")
        rescue
          false
        end
      end

      def self.using_bundler?
        if self.using_gemfile?
          self.delete_gemfile_lock and true
        end
      end

      def self.delete_gemfile_lock
        begin
          File.delete("#{Dir.pwd}/Gemfile.lock")
        rescue
        end
      end
    end
  end
end