class TaskRack < Thor::Group

  	include Thor::Actions

    desc "Generates files needed by Kaya"

# ===============================
# Evaluates prerequisites
#
#

    def check_for_mongo_existance
      begin
        mongo = Kaya::Support::Console.execute "mongo --version"
        mongo_version = mongo.scan(/(\d+\.\d+\.\d+)/).flatten.first
      rescue
        raise "
MONGODB NOT INSTALLED. INSTALL MONGODB BEFORE USING KAYA
to install MongoDB go to: http://docs.mongodb.org/manual/installation/
" if mongo_version.nil?
        end
        puts "MongoDB version installed => #{mongo_version} => OK"
    end


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


      Kaya::Support::Git.checkout_to(selected_branch_name)
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
      template "kaya_conf.tt", "#{Dir.pwd}/kaya/kaya_conf" unless File.exist? "#{Dir.pwd}/kaya/kaya_conf"
    end

    def copy_kaya_log_file
      template "kaya_log.tt", "#{Dir.pwd}/kaya/kaya_log" unless File.exist? "#{Dir.pwd}/kaya/kaya_log"
    end

    def copy_sidekiq_log_file
      template "sidekiq_log.tt", "#{Dir.pwd}/kaya/sidekiq_log" unless File.exist? "#{Dir.pwd}/kaya/sidekiq_log"
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
        # ['*.kaya','kaya_conf','*.html','unicorn.rb', 'config.ru','Gemfile.lock', 'kaya_pids','sidekiq_pids', 'sidekiq_log'].each do |file_name|
        #   f.write "#{file_name}\n" unless content.include? "#{file_name}"
        # end

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
      else
        # Only cucumber projects are allowed to use Kaya (by now)
        raise "There is no Gemfile. Is this a Cucumber Ruby Project?"
      end

    end

    def push_changes
      Kaya::Support::Git.git_add_commit "Kaya: Commit after install command execution"
      Kaya::Support::Git.git_push_origin_to_actual_branch
    end

end
