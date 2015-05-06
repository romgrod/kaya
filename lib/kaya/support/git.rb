# require "git"

module Kaya
  module Support
    class Git

          def self.branch_list
            self.remote_branches.map do |branch|
              branch.gsub("*","").gsub(" ","").gsub("origin/","")
            end.select do |branch|
              not (branch.include? "HEAD" or branch.include? "/")
            end
          end

          def self.remote_branches
            Kaya::Support::Console.execute("git branch -r").split("\n")
          end

          def self.fetch
            Kaya::Support::Console.execute("git fetch")
          end

          def self.branch
            self.branches.select{|branch| branch.include? "*"}.first.gsub("*","").gsub(" ","")
          end

          def self.actual_branch; self.branch; end

          def self.branches
            Kaya::Support::Console.execute("git branch").split("\n")
          end

          def self.git_add_commit msg=nil
            self.add_all
            self.commit msg
          end

          def self.add_all
            Kaya::Support::Console.execute("git add .")
          end

          def self.add_file filename
            Kaya::Support::Console.execute("git add #{filename}")
          end

          def self.push
            Kaya::Support::Console.execute("git push")
          end

          def self.git_push_origin_to branch_name=nil
            branch_name = self.branch if branch_name.nil?
            Kaya::Support::Console.execute("git push origin #{branch_name}")
          end

          def self.reset_hard
            Kaya::Support::Console.execute("git reset --hard")
          end

          def self.reset_hard_and_pull
            self.reset_hard and self.pull
          end

          def self.git_push_origin_to_actual_branch
            branch_name = self.branch
            self.git_push_origin_to branch_name
          end

          def self.git_push_origin_to_actual_branch
            git_push_origin_to(self.actual_branch)
          end

          def self.commit msg = nil
            # self.ensure_being_at_kaya_branch
            msg = "KAYA COMMIT #{Time.new.strftime('%d %m %Y %H:%M:%S')}" if msg.nil?
            Kaya::Support::Console.execute"git commit -m '#{msg}'"
          end

          def self.create_branch_and_checkout branch
            Kaya::Support::Console.execute("git checkout -b #{branch}")
          end

          def self.delete_branch branch
            checkout_to "master"
            Kaya::Support::Console.execute("git branch -D #{branch}")
          end

          # Performs pull from actual branc
          def self.pull
            self.pull_from(self.actual_branch)
          end

          def self.pull_from(branch_name=nil)
            branch_name = self.branch if branch_name.nil?
            Kaya::Support::Console.execute("git pull origin #{branch_name}")
          end

          def self.return_to_branch branch
            self.checkout_to branch
          end

          def self.checkout_to branch
            Kaya::Support::Console.execute("git checkout #{branch}") unless self.actual_branch == branch
          end

          def self.checkout_and_pull_from branch_name=nil
            self.checkout_to(branch_name) if branch_name
            branch_name = self.branch if branch_name.nil?
            self.pull_from branch_name
          end

          # Returns las commit id.
          # This method is used by Execution class to verify changes before each execution
          # @param [String] the name of the project (folder project)
          # @return [String] the id for the las commit
          def self.get_last_commit_id
            self.commits_ids.map do |commit|
                commit.gsub("commit ","")
            end.first
          end

          def self.commits_ids
            self.log.split("\n").select do |line|
                self.is_commit_id? line
            end
          end

          def self.commits
            self.log.split("commit")[1..-1]
          end

          def self.is_commit_id? line
            line.start_with? "commit "
          end

          def self.last_remote_commit
            self.remote_commits.first
          end

          def self.remote_commits
            self.remote_log.split("commit")[1..-1]
          end

          def self.remote_log
            self.fetch
            Kaya::Support::Console.execute "git log origin/#{self.actual_branch}"
          end

          def self.log
            Kaya::Support::Console.execute "git log"
          end

          def self.log_last_commit
            "Commit: #{self.commits.first}"
          end

          def self.last_commit
            self.commits.first
          end

          def self.is_there_commit_id_diff? obtained_commit
              obtained_commit != self.last_commit_id
          end

          def self.remote_url

            res = Kaya::Support::Console.execute("git config --get remote.origin.url").gsub(":","/").gsub("git@", 'http://').chop
            res[0..-5] if res.end_with? ".git"
          end

          # Returns an Array with the existing files on .gitignore
          # @param [Array]
          def self.get_actual_lines
            f = File.open("#{Dir.pwd}/.gitignore","r")
            files_list = []
            f.each_line do |line|
              files_list << line.gsub("\n","").gsub(" ","")
            end
            files_list
          end
    end
  end
end