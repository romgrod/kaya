require 'mongo'

module Kaya
  module Database
    class MongoConnector

      include Mongo

      def initialize(opts={host: "localhost", port: 27017, username: nil, pass: nil})
        set_db_name
        set_client(opts)
        set_db
        authenticate(opts)
        set_suite_collection
        set_custom_param_collection
        set_results_collection
        set_commits_collection
        set_documentation_collection
      end

      def set_db_name
        project_name = Dir.pwd.split("/").last
        @@db_name = "#{project_name}_kaya"
      end

      def set_client opts
        @@client    = MongoClient.new(opts[:host], opts[:port])
      end

      def set_db
        @@db = @@client.db(@@db_name)
      end

      def authenticate opts
        @@auth = @@db.authenticate(opts[:username], opts[:pass]) if opts[:username] and opts[:pass]
      end

      def set_suite_collection
        @@suites  = @@db.collection("suites")
        @@suites.ensure_index({"name" => 1})
      end

      def set_custom_param_collection
        @@custom_params  = @@db.collection("custom_params")
        @@custom_params.ensure_index({"name" => 1})
      end

      def set_commits_collection
        @@commits   = @@db.collection("commits")
      end

      def set_results_collection
        @@results   = @@db.collection("results")
        @@results.ensure_index({"started_at" => 1})
        @@results.ensure_index({"_id" => 1})
      end

      def set_documentation_collection
        @@documentation = @@db.collection("documentation")
      end


      ##########################
      # DOCUMENTATION
      #
      #

      # Removes all documents of documentation from the DB
      def self.clean_documentation
        @@db.drop_collection("documentation")
      end

      # Inserts a document of documentation in the DB
      def self.insert_documentation document
        @@documentation.insert(document)
      end

      # Return an array with all documents of documentation
      def self.get_all_documentation
        @@documentation.find().to_a
      end

      # Returns the body html of a page
      def self.help_body page
        result = @@documentation.find({"title" => page}).to_a.first
        result["body"].to_s if result != nil
      end

      # Returns the title of a page
      def self.help_title page
        result = @@documentation.find({"title" => page}).to_a.first
        result["title"].to_s.gsub('_', ' ').capitalize if result != nil
      end

      # Returns a document from the DB for a certain title
      def self.help_search title
        @@documentation.find({:$or => [{ "title" => /#{title}/ },{ "title" => /#{title.upcase}/ },{ "body" => /#{title}/ }]}).to_a
      end


      ###########################
      # COMMONS
      #
      #

      def self.connected?
        begin
          @@db and true
        rescue
          false
        end
      end

      def self.generate_id
        Time.now.to_f.to_s.gsub( ".","")[0..12].to_i
      end

      # Returns a list of collections
      def self.collections
        ["suites","results","custom_params","commit"]
      end

      # Drops all kaya collections
      def self.drop_collections
        db = self.kaya_db
        collections.each do |collection|
          db.drop_collection(collection) if collection != "documentation"
        end
      end

      def self.kaya_db
        MongoClient.new().db(@@db_name)
      end


      ##################################
      # COMMITS
      #
      #


      # Saves commit information
      # @param [Hash] commit_info = {"_id" => Fixnum, "commit_id" => String, "info" => String}
      def self.insert_commit commit_info
        @@commits.insert({"_id" => self.generate_id, "log" => commit_info})
      end

      # Returns last saved commit info
      # @return [Hash] if exist
      def self.last_commit
        data = @@commits.find_one({})
        data["log"] if data
      end

      ##################################
      # SUITES
      #

      # Inserts a suite in suites collection
      # @param [Hash] suite_data (see suite_data_structure method)
      def self.insert_suite suite_data
        @@suites.insert(suite_data)
      end

      # Update record for a given suite
      # @param [Hash] suite_data
      def self.update_suite suite_data
        @@suites.update( {"_id" => suite_data["_id"]}, suite_data)
      end

      # Returns the entire record for a given suite name
      # @param [String] suite_name
      # @return [Hash] all suite data
      def self.suite_data_for suite_id
        suite_id = suite_id.to_i if suite_id.respond_to? :to_i
        @@suites.find_one({"_id" => suite_id})
      end

      def self.suite_data_for_name(suite_name)
        @@suites.find_one({"name" => suite_name})
      end

      # Returns the _id for a given suite name
      # @param [String] suite_name
      # @return [String] _id
      def self.suite_id_for suite_name
        res = @@suites.find_one({"name" => suite_name}, {:fields => ["_id"]})
        res["_id"] if res
      end

      def self.suites active=true
        @@suites.find({}, :sort => ["last_result", -1]).to_a
      end

      # Returns all active suites
      def self.all_suites
        self.suites
      end

      def self.running_suites
        @@suites.find({"status" => "RUNNING"}).to_a
      end

      def self.running_for_suite suite_name
        @@suites.find({"name" => suite_name, "status" => "RUNNING"}).to_a
      end

      def self.active_suites
        self.all_suites
      end

      def self.delete_suite suite_id
        @@suites.remove({"_id" => suite_id})
      end

    ########################################
    # CUSTOM PARAMS
    #
    #
    #

    def self.custom_params_list
      @@custom_params.find({}).to_a
    end

    def self.insert_custom_param custom_param_data
      @@custom_params.insert(custom_param_data)
    end

    # Update record for a given custom param
    # @param [Hash] custom_param_data
    def self.update_custom_param custom_param_data
      id = custom_param_data["_id"].to_i if custom_param_data["_id"].respond_to? :to_i
      @@custom_params.update( {"_id" => custom_param_data["_id"]}, custom_param_data)
    end

    # Returns the entire record for a given id
    # @param [String] custom_param_id
    # @return [Hash] all custom param data
    def self.get_custom_param custom_param_id
      custom_param_id = custom_param_id.to_i if custom_param_id.respond_to? :to_i
      @@custom_params.find_one({"_id" => custom_param_id})
    end

    def self.param_id_for_name custom_param_name
      res = self.custom_param_for_name custom_param_name
      res["_id"] if res
    end

    def self.custom_param_for_name custom_param_name
      @@custom_params.find_one({"name" => custom_param_name})
    end

    def self.exist_custom_param_name? name
      !self.param_id_for_name(name).nil?
    end

    def self.exist_custom_param_id? param_id
      !@@custom_params.find_one({"_id" => param_id}).nil?
    end

    def self.delete_custom_param custom_param_id
      custom_param_id = custom_param_id.to_i if custom_param_id.respond_to? :to_i
      @@custom_params.remove({"_id" => custom_param_id})
    end


    ######################################3
    # RESULTS
    #
    #

      # Creates a result data andc
      # returns de id for that register
      # @param [Hash] execution_data
      # @return [String] id for created result
      def self.insert_result(result_data)
        begin
          @@results.insert(result_data)
          true
        rescue
          false
        end
      end

      # Returns all results for a given suite_id
      def self.results_for suite_id
        @@results.find({"suite.id" => ensure_int(suite_id)}, :sort => ["started_at", -1]).to_a
      end

      # Updates result register with the given data
      #
      def self.update_result result_data_structure
        begin
          @@results.update( {"_id" => result_data_structure["_id"]}, result_data_structure)
          true
        rescue
          false
        end
      end

      def self.result_data_for_id(result_id)
        @@results.find_one({"_id" => ensure_int(result_id)})
      end

      def self.running_results_for_suite_id suite_id
        @@results.find({"suite.id" => suite_id, "status" => "running"}, :sort => ["started_at", -1]).to_a
      end


      # Returns value as Fixnum if it is not
      # @param [Object] value
      # @return [Fixnum]
      def self.ensure_int(value)
        value and value.to_i if value.respond_to? :to_i
      end

      # Returns all result
      # @return [Array] results from results coll
      def self.all_results
        @@results.find({}, :sort => ['_id', -1]).to_a
      end

      def self.all_results_ids
        @@results.find({},{"_id" => 1}, :sort => ['_id', -1]).to_a
      end

      def self.find_results_for_key key
        @@results.find({$or => [{"suite.name" => /#{key}/}, {"execution_name" => /#{key}/ }, {"summary" => /#{key}/ }, {"command" => /#{key}/ }]}).to_a
      end

      def self.last_result_for_suite suite_id
        @@results.find_one({}, :sort => ['_id', -1])
      end

      def self.find_results_for_status status
        @@results.find({$or => [{"summary" => /#{status}/}, {"status" => /#{status}/ }]},{"_id" => 1}).to_a
      end
    end
  end
end
