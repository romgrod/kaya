module Kaya
  module Support
    class Update

      @gem_folder = File.expand_path("../../../../", __FILE__) + "/lib/generators/templates/"
      @project_folder = "#{Dir.pwd}/kaya/"

      # Returns the most updated version of kaya_conf file, and updates the file if neded
      def self.kaya_conf
        update_json_file "kaya_conf"
      end

      # Returns the updated version of a json file, and writes it in the disk
      #
      # It updates a file located in kaya folder inside the project, with all new keys and sub-keys in of it's template file

      # It also removes all keys not longer present in the template file.

      def self.update_json_file name
        file = JSON.parse(IO.read(@project_folder + name))
        # template = JSON.parse(IO.read(@gem_folder + name + ".tt"))

        # modified = false

        # deprecated_keys = file.keys - template.keys
        # if deprecated_keys.any?
        #   deprecated_keys.each { |key| file.delete key }
        #   modified = true
        #   puts "The following keys: #{deprecated_keys} are deprecated and are going to be removed from your #{name} file.".colorize(:green)
        # end

        # if file.keys.sort != template.keys.sort
        #   puts "The following keys: #{template.keys - file.keys} are new and are going to be added to your #{name} file.".colorize(:green)
        #   modified = true
        #   file.merge! template
        # end

        # file.keys.each do |key|
        #   if file[key].class == Hash
        #     deprecated_sub_keys = file[key].keys - template[key].keys
        #     if deprecated_sub_keys.any?
        #       deprecated_sub_keys.each{ |sub_key| file[key].delete sub_key }
        #       modified = true
        #       puts "The following sub keys: #{deprecated_sub_keys} from #{key} key are deprecated and are going to be removed from your #{name} file.".colorize(:green)
        #     end
        #     if file[key].keys.sort != template[key].keys.sort
        #       puts "The following sub keys: #{template[key].keys - file[key].keys} from #{key} key are new and are going to be added to your #{name} file.".colorize(:green)
        #       modified = true
        #       file[key].merge! template[key]
        #     end
        #   end
        # end

        # if modified
        #   File.write(@project_folder + name, JSON.pretty_generate(file))
        #   puts "Done.".colorize(:green)
        # end

        file

      end
    end
  end
end

