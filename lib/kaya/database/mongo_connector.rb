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
        @@suites.ensure_index({"last_result" => 1})
      end

      def set_commits_collection
        @@commits   = @@db.collection("commits")
      end

      def set_results_collection
        @@results   = @@db.collection("results")
        @@results.ensure_index({"_id" => 1})
        @@results.ensure_index({"started_at" => 1, "_id" => 1})
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
        ["suites","results"]
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
        data = @@commits.find({}).to_a.last
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
        @@suites.find({"_id" => suite_id}).to_a.first
      end

      def self.suite_data_for_name(suite_name)
        id = self.suite_id_for(suite_name)
        @@suites.find({"_id" => id}).to_a.first
      end

      # Returns the _id for a given suite name
      # @param [String] suite_name
      # @return [String] _id
      def self.suite_id_for suite_name, active=nil
        criteria = {"name" => suite_name}
        criteria.store("active",true) if active
        result = @@suites.find(criteria).to_a.first
        result.nil? ? nil : result["_id"]
      end

      def self.suites active=true
        criteria ={}
        criteria["active"]=active if active
       @@suites.ensure_index({"last_result" => 1})
       @@suites.find(criteria, :sort => ["last_result", -1]).to_a || []
      end

      # Returns all active suites
      def self.all_suites
        @@suites.find({"active" => true}).to_a
      end

      def self.active_suites
        self.suites true
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
        @@results.ensure_index({"started_at" => 1, "_id" => 1})
        res = @@results.find({}, :sort => ["started_at", -1]).to_a
        unless res.empty?
          res.select{|result| result["suite"]["id"]==ensure_int(suite_id)}
        else
          []
        end
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

      def self.results_for_suite_id_and_ip suite_id, ip
        results = self.find_results_for_ip(ip)
        if results
          results.select{|result| result["suite"]["id"]==suite_id}
        else
          []
        end
      end

      def self.result_data_for_id(result_id)
        @@results.find({"_id" => ensure_int(result_id)}).to_a.first
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
        @@results.ensure_index({"started_at" => 1, "_id" => 1})
        res = @@results.find({}, :sort => ['_id', -1])
        if res
          res.to_a
        else
          []
        end
      end

      def self.all_results_ids
        all_results.map{|res| res['_id']}
      end

      def self.find_results_for_key key
        all_actual_results = self.all_results
        if !all_actual_results.empty?
          all_actual_results.select do |result|
            result["suite"]["name"].include?(key) or result["execution_name"].include?(key) or result["summary"].include?(key) or result["command"].include?(key)
          end
        end
      end

      def self.find_results_for_ip ip
        @@results.find({"ip" => ip}, :sort =>["started_at", -1]).to_a
      end

      def self.find_results_for_status status
        all_actual_results = self.all_results
        if !all_actual_results.empty?
          all_actual_results.select do |result|
            result["summary"].include?(status) or result["status"].include?(status)
          end.map{|result| result["_id"]}
        end
      end
    end
  end
end
