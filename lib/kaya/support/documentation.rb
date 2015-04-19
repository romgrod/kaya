module Kaya
  module Support
    class Documentation

      @@main_folder = File.expand_path("../../../../", __FILE__) + "/"
      @@docs_folder = @@main_folder + "documentation/"

      @@folders_to_search = [@@main_folder, @@docs_folder]


      def self.load_documentation
        print "\nLoading documentation..."
        Kaya::Database::MongoConnector.clean_documentation
        @@folders_to_search.each { |folder| self.open_files folder }
        print "OK"
      end

      def self.open_files folder
        Dir.glob(folder + "*.md") do |md_file|
          name = md_file.split("/").last.gsub('.md','')
          text = File.read(md_file)
          Kaya::Database::MongoConnector.insert_documentation self.generate_entry(name,text)
        end
      end

      def self.generate_entry name, text
        {
            "title" => name,
            "body" => text
        }
      end
    end
  end
end