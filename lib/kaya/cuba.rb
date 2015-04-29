require "cuba"

include Mote::Helpers

Cuba.define do

  $suites_counter = 0

  request = Kaya::Support::Request.new(req)

  $K_LOG.debug "REQUEST '#{request.path}#{request.path_info}' FROM IP: '#{request.ip}'" if $K_LOG

  begin


# ========================================================================
# COMMON INIT
#
#
    Kaya::Support::Configuration.get

    Kaya::Database::MongoConnector.new Kaya::Support::Configuration.db_connection_data

    on get do

      HOSTNAME = Kaya::Support::Configuration.hostname

# ========================================================================
# HELP
#
#
      on "#{HOSTNAME}/kaya/help/:page" do |page|
        query_string = Kaya::Support::QueryString.new req
        template = Mote.parse(File.read("#{Kaya::View.path}/help.mote"),self, [:page, :query_string])
        res.write template.call(page:page, query_string:query_string.s)
      end

      on "#{HOSTNAME}/kaya/help" do
        res.redirect "/#{HOSTNAME}/kaya/help/main"
      end


# ========================================================================
# VIEW ROUTES
#
#
#
      on "#{HOSTNAME}/kaya/results/log/:result_id" do |result_id|
        result = Kaya::Results::Result.get(result_id)
        res.redirect "/#{HOSTNAME}/kaya/404/There%20is%20no%20result%20for%20id=#{result_id}" if result.nil?
        result.mark_as_saw! if (result.finished? or result.stopped?)
        template = Mote.parse(File.read("#{Kaya::View.path}/results/console.mote"),self, [:result])
        res.write template.call(result:result)
      end


      on "#{HOSTNAME}/kaya/results/report/:result_id" do |result_id|
        result = Kaya::Results::Result.get(result_id)
        res.redirect "/#{HOSTNAME}/kaya/404/There%20is%20no%20result%20for%20id=#{result_id}" if result.nil?
        result.mark_as_saw! if (result.finished? or result.stopped?)
        if result.finished? and !result.stopped? and result.html_report.size > 0
          template = Mote.parse(File.read("#{Kaya::View.path}/results/report.mote"),self, [:result])
          res.write template.call(result:result)
        else
          res.redirect "#{HOSTNAME}/kaya/results/log/result_id"
        end
      end

      on "#{HOSTNAME}/kaya/results/:result_id/reset" do |result_id|
        result = Kaya::API::Execution.reset(result_id)
        res.redirect "/#{HOSTNAME}/kaya/results?msg=#{result['message']}"
      end

      on "#{HOSTNAME}/kaya/results/suite/:suite_name" do |suite_name|
        query_string = Kaya::Support::QueryString.new req
        suite_name.gsub!("%20"," ")
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :query_string, :suite_name, :log_name])
        res.write template.call(section:"Results", query_string:query_string, suite_name:suite_name, log_name:nil)
      end

      on "#{HOSTNAME}/kaya/results/all" do
        query_string = Kaya::Support::QueryString.new req
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :query_string, :suite_name, :log_name])
        res.write template.call(section:"All Results", query_string:query_string, suite_name:nil, log_name:nil)
      end

      on "#{HOSTNAME}/kaya/results" do
        query_string = Kaya::Support::QueryString.new req
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :query_string, :suite_name, :log_name])
        res.write template.call(section:"Results", query_string:query_string, suite_name:nil, log_name:nil)
      end

      on "#{HOSTNAME}/kaya/suites/:suite/run" do |suite_name|
        query_string = Kaya::Support::QueryString.new req
        result = Kaya::API::Execution.start suite_name, query_string.values

        path = "/#{HOSTNAME}/kaya/suites"
        path += "?msg=#{result['message']}. " if result["message"]
        path += "Execution id=#{result["execution_id"]}" if result["execution_id"]

        res.status= result["status"]
        res.redirect path
      end

      on "#{HOSTNAME}/kaya/suites/:suite_name" do |suite_name|
        query_string = Kaya::Support::QueryString.new req
        (Kaya::Support::Git.reset_hard and Kaya::Support::Git.pull) if Kaya::Support::Configuration.use_git?
        Kaya::Suites.update_suites
        suite_name.gsub!("%20"," ")
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :query_string, :suite_name, :log_name])
        res.write template.call(section:"Test Suites", query_string:query_string, suite_name:suite_name, log_name:nil)
      end

      on "#{HOSTNAME}/kaya/suites" do
        query_string = Kaya::Support::QueryString.new req
        Kaya::Suites.update_suites
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :query_string, :suite_name, :log_name])
        res.write template.call(section:"Test Suites", query_string:query_string, suite_name:nil, log_name:nil)
      end

      on "#{HOSTNAME}/kaya/logs/:log_name" do |log_name|
        query_string = Kaya::Support::QueryString.new req
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :query_string, :suite_name, :log_name])
        res.write template.call(section:"Logs", query_string:query_string, suite_name:nil, log_name:log_name)
      end

# ========================================================================
# SCREENSHOTS
#
#

      on "#{HOSTNAME}/kaya/screenshot/:file_name" do |file_name|
        template = Mote.parse(File.read("#{Kaya::View.path}/screenshot.mote"),self, [:file_name])
        res.write template.call(file_name:file_name)
      end

# ========================================================================
# FEATURE SHOW
#
#
      on "#{HOSTNAME}/kaya/features/file" do
        template = Mote.parse(File.read("#{Kaya::View.path}/features.mote"),self, [:query_string])
        res.write template.call(query_string:Kaya::Support::QueryString.new(req))
      end

# ========================================================================
# FEATURES / LIST
#
#
      on "#{HOSTNAME}/kaya/features" do
        template = Mote.parse(File.read("#{Kaya::View.path}/features.mote"),self, [:query_string])
        res.write template.call(query_string:Kaya::Support::QueryString.new(req))
      end


# ========================================================================
# API ROUTES
#
#
#
      on "#{HOSTNAME}/kaya/api/version" do
        output = { "version" => Kaya::VERSION}
        res.write output.to_json
      end

      on "#{HOSTNAME}/kaya/api/results/:id/data" do |result_id|
        output = Kaya::API::Result.data(result_id)
        res.write output.to_json
      end

      on "#{HOSTNAME}/kaya/api/results/:id/status" do |result_id|
        output = Kaya::API::Result.status(result_id)
        res.write output.to_json
      end

      on "#{HOSTNAME}/kaya/api/results/:id" do |result_id|
        res.write(Kaya::API::Result.info(result_id).to_json)
      end

      on "#{HOSTNAME}/kaya/api/results/:id/reset" do |result_id|
        result = Kaya::API::Execution.reset(result_id)
        res.write result.to_json
      end

      on "#{HOSTNAME}/kaya/api/suites/:suite/run" do |suite_name|
        query_string = Kaya::Support::QueryString.new req
        result = Kaya::API::Execution.start suite_name, query_string.values
        res.write result.to_json
      end

      on "#{HOSTNAME}/kaya/api/suites/:id/status" do |suite_id|
        output = Kaya::API::Suite.status(suite_id.to_i)
        res.write output.to_json
      end

      on "#{HOSTNAME}/kaya/api/suites/running" do
        output = Kaya::API::Suites.list({running:true})
        res.write output.to_json
      end

      on "#{HOSTNAME}/kaya/api/suites/active" do
        output = Kaya::API::Suites.list({"active" => true})
        res.write output.to_json
      end

      on "#{HOSTNAME}/kaya/api/suites/unactive" do
        output = Kaya::API::Suites.list({"active" => false})
        res.write output.to_json
      end

      on "#{HOSTNAME}/kaya/api/suites/:id" do |suite_id|
        output = Kaya::API::Suite.info(suite_id)
        res.write output.to_json
      end

      on "#{HOSTNAME}/kaya/api/suites" do
        (Kaya::Support::Git.reset_hard and Kaya::Support::Git.pull) if Kaya::Support::Configuration.use_git?
        Kaya::Suites.update_suites
        output = Kaya::API::Suites.list({"active" => true})
        res.write output.to_json
      end

      on "#{HOSTNAME}/kaya/api/results" do
        output = Kaya::API::Results.show()
        res.write output.to_json
      end

      on "#{HOSTNAME}/kaya/api/error" do
        query_string = Kaya::Support::QueryString.new req
        output = Kaya::API::Error.show(query_string)
        res.write output.to_json
      end

      on "#{HOSTNAME}/kaya/api" do
        response = {"message" => "Please, refer to /#{HOSTNAME}/kaya/help/api for more information"}
        res.write response.to_json
      end



# ========================================================================
# CLEAN
#
#
      on "#{HOSTNAME}/kaya/clean" do
        Kaya::Support::Clean.start
        res.redirect "/#{HOSTNAME}/kaya/suites?msg=Suites and results cleanned"
      end

# ========================================================================
# REDIRECTS
#
      on "#{HOSTNAME}/kaya/help" do
        res.redirect "/#{HOSTNAME}/kaya/help/main"
      end

      on "#{HOSTNAME}/kaya/404" do
        template = Mote.parse(File.read("#{Kaya::View.path}/not_found.mote"),self, [])
        res.write template.call()
      end

      on "#{HOSTNAME}/kaya/:any" do
          res.redirect("/#{HOSTNAME}/kaya/suites")
      end

      on "#{HOSTNAME}/kaya" do
        res.redirect "/#{HOSTNAME}/kaya/suites"
      end

      on "favicon" do
        res.write ""
      end

      on "#{HOSTNAME}" do
        res.redirect "/#{HOSTNAME}/kaya/suites"
      end

      on root do
        res.redirect "/#{HOSTNAME}/kaya/suites"
      end
    end
  rescue => e
    $K_LOG.error "Cuba: #{e} #{e.backtrace}" if $K_LOG
    template = Mote.parse(File.read("#{Kaya::View.path}/error_handler.mote"),self, [:exception])
    res.write template.call(exception:e)
  end
end