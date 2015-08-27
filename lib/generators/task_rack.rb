module Kaya
  class TaskRack < Thor::Group

    	include Thor::Actions

      desc "Generates files needed by Kaya"

  # ===============================
  # Evaluates prerequisites
  #
  #

  #     def check_for_mongo_existance
  #       begin
  #         mongo = Kaya::Support::Console.execute "mongo --version"
  #         mongo_version = mongo.scan(/(\d+\.\d+\.\d+)/).flatten.first
  #       rescue
  #         raise "
  # MONGODB NOT INSTALLED. INSTALL MONGODB BEFORE USING KAYA
  # to install MongoDB go to: http://docs.mongodb.org/manual/installation/
  # " if mongo_version.nil?
  #         end
  #         puts "MongoDB version installed => #{mongo_version} => OK"
  #     end


      def check_redis_existance
        redis = Kaya::Support::Console.execute "redis-server -v"
        raise "
  REDIS SERVER IS NOT INSTALLED ON YOUR SYSTEM.
  INSTALL REDIS SERVER BEFORE USING KAYA
  to install Redis go to:
        " unless redis =~ /Redis server v=\d+\.\d+\.\d+/
      end


      def choose_working_branch

        # Gets the list of branches
        branch_list=Kaya::Support::Git.branch_list
        branch_list << "local files"

        begin
          system "clear"
          Kaya::Support::Logo.show
          puts "
  You have to choose one of the following branches to tell Kaya where to work with:"
          # Print the options
          branch_list.each_with_index do |branch_name, index|
            puts "\t(#{index + 1}) - #{branch_name}"
          end
          print "\n\t     Your option:"; option = STDIN.gets

          #Converted to Fixnum
          option = option.gsub!("\n","").to_i

        end until (1..branch_list.size).include? option


        selected_branch_name = branch_list[option-1]
        puts "
        Lets work on '#{selected_branch_name}'

        "
        @local = selected_branch_name == "local files"
        Kaya::Support::Git.checkout_to(selected_branch_name) unless selected_branch_name == "local files"

      end

  # ==============================
  # Start install task
  #
  #
  #
      def self.source_root
        File.dirname(__FILE__) + "/templates/"
      end

      def creates_kaya_folder
        empty_directory "kaya"
      end

      def creates_kaya_temp_folder
        empty_directory "kaya/temp"
      end

      def creates_kaya_out
        empty_directory "kaya/out"
      end

      def creates_kaya_log_dir
        empty_directory "kaya/logs"
      end

      def creates_kaya_pids_dir
        empty_directory "kaya/pids"
      end

      def creates_kaya_conf_dir
        empty_directory "kaya/conf"
      end



      def copy_server_file
        unless File.exist? "#{Dir.pwd}/kaya/config.ru"
      	 template "config.ru.tt", "#{Dir.pwd}/kaya/config.ru"

        else

          if yes?("\n  It seems that you already have a config.ru file. DO YOU WANT TO REPLACE IT? (yes/no)", color = :green)
            template "config.ru.tt", "#{Dir.pwd}/kaya/config.ru"
          else
            raise "The existing config.ru file must be replaced with config.ru file from Kaya"
          end
        end
      end


      def copy_kaya_conf
        template "kaya.conf.tt", "#{Dir.pwd}/kaya/conf/kaya.conf" unless File.exist? "#{Dir.pwd}/kaya/conf/kaya.conf"
      end

      def updating_git_usage_as_false_if_local
        if @local
          config_file_content = JSON.parse(IO.read("#{Dir.pwd}/kaya/conf/kaya.conf"))
          config_file_content["USE_GIT"] = false
          content_to_save = config_file_content.to_json.gsub(",",",\n").gsub("{","{\n")
          IO.write("#{Dir.pwd}/kaya/conf/kaya.conf",content_to_save)
        end
      end

      def copy_kaya_log_file
        template "kaya.log.tt", "#{Dir.pwd}/kaya/logs/kaya.log" unless File.exist? "#{Dir.pwd}/kaya/logs/kaya.log"
      end

      def copy_sidekiq_log_file
        template "sidekiq.log.tt", "#{Dir.pwd}/kaya/logs/sidekiq.log" unless File.exist? "#{Dir.pwd}/kaya/logs/sidekiq.log"
      end

      def copy_unicorn_config_file
        unless File.exist? "#{Dir.pwd}/kaya/unicorn.rb"
          template "unicorn.rb.tt", "#{Dir.pwd}/kaya/unicorn.rb"
          @unicorn_created = true
        end
      end

      def update_gitignore
        path = "#{Dir.pwd}/.gitignore"
        if File.exist? path
          f = File.open(path, "a+")
          content = ""
          f.each_line{|line| content += line}
          f.write "\n" unless content[-1] == "\n"
          f.write "kaya/\n" unless content.include? "kaya/"
          f.write "kaya/*\n" unless content.include? "kaya/*"


          f.close
        end
      end

      def update_gemfile
        path = "#{Dir.pwd}/Gemfile"
        if File.exist? path
          f = File.open(path, "a+")
          content = ""
          f.each_line{|line| content += line}
          f.write "\n" unless content[-1] == "\n"
          ["gem 'kaya'"].each do |file_name|
            f.write "#{file_name}\n" unless content.include? "#{file_name}"
          end
        end

      end

      def push_changes
        unless @local
          Kaya::Support::Git.git_add_commit "Kaya: Commit after install command execution"
          Kaya::Support::Git.git_push_origin_to_actual_branch
        end
      end

  end
end