require "cuba"

include Mote::Helpers

Kaya::Support::Configuration.get

Kaya::Database::MongoConnector.new Kaya::Support::Configuration.db_connection_data

Cuba.define do

  $tasks_counter = 0

  request = Kaya::Support::Request.new(req)

  $K_LOG.debug "REQUEST '#{request.request}" if $K_LOG

  begin


# ========================================================================
# COMMON INIT
#
#
    # Kaya::Support::Configuration.get

    # Kaya::Database::MongoConnector.new Kaya::Support::Configuration.db_connection_data

    $K_LOG.debug "HOSTNAME:#{HOSTNAME = Kaya::Support::Configuration.hostname}"

    on post do

      on "#{HOSTNAME}/kaya/admin/reload" do
        on true do

          # Guarda el nuevo archivo de configuración si es válido

          Kaya::Support::Configuration.get
        end
      end

      on "#{HOSTNAME}/kaya/admin/delete-custom-param" do

        on true do

          data = req.params.dup

          data["_id"] = data["_id"].to_i

          response = Kaya::API::CustomParams.set data # Creates or update

          path = "/#{HOSTNAME}/kaya/admin/custom/params"
          path += "?msg=#{response[:message]}" if response[:message]

          res.redirect path
        end

      end

      # TO EDIT OR CREATE CUSTOM PARAM
      on "#{HOSTNAME}/kaya/admin/custom-param" do

        on true do

          data = req.params.dup

          $K_LOG.debug "data is => #{data}"

          response = Kaya::API::CustomParams.set data # Creates or update

          path = "/#{HOSTNAME}/kaya/admin/custom/params"

          # Si success es true
          $K_LOG.debug "#{response}"

          unless response[:success]

            path += "/#{data['_id']}" if data["_id"]
            path += "/#{data['action']}"
          end
          path += "?msg=#{response[:message]}"

          path += "&name=#{data['name']}&action=#{data['action']}&type=#{data['type']}&value=#{data['value']}&options=#{data['options']}&required=data['required']&clean=false" unless response[:success]

          res.redirect path

        end

      end


      on "#{HOSTNAME}/kaya/admin/tasks/add-edit" do

        on true do

          data = req.params.dup

          $K_LOG.debug "#{data['action']} Task - Recieved data => #{data}"

          # Extracts custom params
          custom_params = data.keys.select{|field| field.start_with? "custom_param_" and data.delete(field)}.inject([]){|res, value| res<<value.gsub("custom_param_","").to_i; res}

          data["custom_params"] = custom_params

          $K_LOG.debug "DATA SENT TO Task.set is => #{data}"

          response = Kaya::API::Tasks.set data # Creates or update

          path = "/#{HOSTNAME}/kaya/admin/tasks"

          $K_LOG.debug "#{response}"

          unless response[:success]

            path += "/#{data['_id']}" if data["_id"]
            path += "/#{data['action']}"
          else
            path+= "/list"
          end
          path += "?msg=#{response[:message]}"

          path += "&name=#{data['name']}&action=#{data['action']}&type=#{data['type']}&value=#{data['value']}&options=#{data['options']}&required=data['required']&clean=false" unless response[:success]

          res.redirect path

        end
      end

      on "#{HOSTNAME}/kaya/admin/tasks/delete" do

        on true do

          data = req.params.dup

          $K_LOG.debug "DATA SENT TO Task.delete is => #{data}"

          result = Kaya::Tasks.delete! data["task_id"]
          path = "/#{HOSTNAME}/kaya/admin/tasks/list"

          path += "?msg=#{result[:message]}"

          res.redirect path
        end
      end
    end




    on get do

# ========================================================================
# HELP
#
#
      on "#{HOSTNAME}/kaya/help/:page" do |page|
        args ={page:page}
        template = Mote.parse(File.read("#{Kaya::View.path}/help.mote"),self, [:args])
        res.write template.call(:args => args)
      end

      on "#{HOSTNAME}/kaya/help" do
        res.redirect "/#{HOSTNAME}/kaya/help/main"
      end


# ========================================================================
# VIEW ROUTES
#
#
#
      # INVERTIR /log con  /:result_id

      on "#{HOSTNAME}/kaya/results/log/:result_id" do |result_id|
        # result = Kaya::Results::Result.get(result_id)
        # res.redirect "/#{HOSTNAME}/kaya/404/There%20is%20no%20result%20for%20id=#{result_id}" if result.nil?
        # result.mark_as_saw! if (result.finished? or result.stopped?)
        template = Mote.parse(File.read("#{Kaya::View.path}/results/console.mote"),self, [:result_id])
        res.write template.call(result_id:result_id)
      end


      # INVERTIR /log con  /:result_id
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

      on "#{HOSTNAME}/kaya/results/task/:task_name" do |task_name|
        query_string = Kaya::Support::QueryString.new req
        task_name.gsub!("%20"," ")
        args = {task_name:task_name, query_string:query_string}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Results", args:args)
      end

      on "#{HOSTNAME}/kaya/results/all" do
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"All Results", args:args)
      end

      on "#{HOSTNAME}/kaya/results" do
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Results", args:args)
      end

## ========================================================================
# TASKS CRUD
#
#
#

      on "#{HOSTNAME}/kaya/admin/tasks/list" do
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Edit Tasks", args:{:query_string => Kaya::Support::QueryString.new(req)})
      end


      on "#{HOSTNAME}/kaya/admin/tasks/new" do
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string, action:"new"}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Add Task", args:args)
      end

      on "#{HOSTNAME}/kaya/admin/tasks/:task_id/edit" do |task_id|
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string, action:"edit"}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Edit Task", args:args)

      end

      on "#{HOSTNAME}/kaya/admin/tasks/:task_id/delete" do |task_id|
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string, task_id:task_id}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Delete Task", args:args)
      end

      on "#{HOSTNAME}/kaya/admin/tasks/:task_id/view" do |task_id|
        # query_string = Kaya::Support::QueryString.new req
        # args = {query_string:query_string}
        # template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        # res.write template.call(section:"Delete Task", args:args)
        res.write "VIEWING TASK WITH ID: #{task_id}"
      end

      on "#{HOSTNAME}/kaya/admin/custom/params/new" do
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string, action:"new"}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"New Custom Param", args:args)
      end

      on "#{HOSTNAME}/kaya/admin/custom/params/:custom_id/edit" do |custom_param_id|
        query_string = Kaya::Support::QueryString.new req
        res.redirect "/#{HOSTNAME}/kaya/admin/custom/params?msg=Could not find Custom Parameter" if Kaya::Tasks::Custom::Params.exist? custom_param_id
        args = {query_string:query_string, custom_param_id:custom_param_id, action:"edit"}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Edit Custom Param", args:args)
      end

      on "#{HOSTNAME}/kaya/admin/custom/params/:custom_id/delete" do |custom_param_id|
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string, custom_param_id:custom_param_id, action:"delete"}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Delete Custom Param", args:args)
      end

      on "#{HOSTNAME}/kaya/admin/custom/params" do
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Custom Params", args:args)
      end

      on "#{HOSTNAME}/kaya/admin/configuration" do
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Configuration", args:args)
      end




## ===============================================
# TASKS
#
#

      on "#{HOSTNAME}/kaya/tasks/:task/run" do |task_name|
        query_string = Kaya::Support::QueryString.new req
        task_name.gsub!("%20"," ")
        result = Kaya::API::Execution.start task_name, query_string.values
        $K_LOG.debug "result => #{result}"
        path = if result["execution_id"]
         "/#{HOSTNAME}/kaya/message/task/#{result['execution_id']}"
        else
          "/#{HOSTNAME}/kaya/error?msg=#{result['message']}"
        end
        res.redirect path
      end


      on "#{HOSTNAME}/kaya/message/task/:result_id" do |result_id|
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string, result_id:result_id}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Task Message", args:args)
      end


      on "#{HOSTNAME}/kaya/tasks/:task_name" do |task_name|
        query_string = Kaya::Support::QueryString.new req
        task_name.gsub!("%20"," ")
        args = {query_string:query_string, task_name:task_name}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Tasks", args:args)
      end

      on "#{HOSTNAME}/kaya/tasks" do
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Tasks", args:args)
      end

## ========================================================================
# TESTS
#
#
#

      on "#{HOSTNAME}/kaya/tests/:task/run" do |task_name|
        query_string = Kaya::Support::QueryString.new req
        task_name.gsub!("%20"," ")
        result = Kaya::API::Execution.start task_name, query_string.values, "test"
        $K_LOG.debug "result => #{result}"
        path = if result["execution_id"]
         "/#{HOSTNAME}/kaya/message/test/#{result['execution_id']}"
        else
          "/#{HOSTNAME}/kaya/error?msg=#{result['message']}"
        end
        res.redirect path
      end

      on "#{HOSTNAME}/kaya/message/test/:result_id" do |result_id|
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string, result_id:result_id}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Test Message", args:args)
      end

      on "#{HOSTNAME}/kaya/tests/:task_name" do |task_name|
        query_string = Kaya::Support::QueryString.new req
        $K_LOG.debug "task_name => #{task_name}"
        task_name.gsub!("%20"," ")
        args = {query_string:query_string, task_name:task_name}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Tests", args:args)
      end

      on "#{HOSTNAME}/kaya/tests" do
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Tests", args:args)
      end



## ========================================================================
# LOGS
#
#



      on "#{HOSTNAME}/kaya/logs/:log_name" do |log_name|
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string, log_name:log_name}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Log", args:args)
      end

      on "#{HOSTNAME}/kaya/logs" do
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Logs", args:args)
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
        query_string = Kaya::Support::QueryString.new req
        output = Kaya::API::Result.data(result_id, query_string.raw)
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

      on "#{HOSTNAME}/kaya/api/tasks/:task/run" do |task_name|
        task_name.gsub!("%20"," ")
        query_string = Kaya::Support::QueryString.new req
        result = Kaya::API::Execution.start task_name, query_string.values
        res.write result.to_json
      end

      on "#{HOSTNAME}/kaya/api/tests/:task/run" do |task_name|
        task_name.gsub!("%20"," ")
        query_string = Kaya::Support::QueryString.new req
        result = Kaya::API::Execution.start task_name, query_string.values
        res.write result.to_json
      end

      on "#{HOSTNAME}/kaya/api/tasks/:id/status" do |task_id|
        output = Kaya::API::Task.status(task_id.to_i)
        res.write output.to_json
      end

      on "#{HOSTNAME}/kaya/api/tests/:id/status" do |task_id|
        output = Kaya::API::Task.status(task_id.to_i)
        res.write output.to_json
      end

      on "#{HOSTNAME}/kaya/api/tasks/running" do
        output = Kaya::API::Tasks.list({running:true, type:"task"})
        res.write output.to_json
      end

      on "#{HOSTNAME}/kaya/api/tests/running" do
        output = Kaya::API::Tasks.list({running:true, type:"task"})
        res.write output.to_json
      end

      on "#{HOSTNAME}/kaya/api/tasks/:id" do |task_id|
        output = Kaya::API::Task.info(task_id)
        res.write output.to_json
      end

      on "#{HOSTNAME}/kaya/api/tests/:id" do |task_id|
        output = Kaya::API::Task.info(task_id)
        res.write output.to_json
      end

      on "#{HOSTNAME}/kaya/api/tasks" do
        output = Kaya::API::Tasks.list({type:"task"})
        res.write output.to_json
      end

      on "#{HOSTNAME}/kaya/api/tests" do
        output = Kaya::API::Tasks.list({type:"test"})
        res.write output.to_json
      end

      on "#{HOSTNAME}/kaya/api/results" do
        output = Kaya::API::Results.show()
        res.write output.to_json
      end

      on "#{HOSTNAME}/kaya/api/custom/params/:name/value" do |name|
        output = {}
        param = Kaya::API::CustomParams.get(name)
        output["app"] = Kaya::Support::Configuration.project_name
        output["request"] = "Custom Parameter value"
        output["custom_param_name"] = param["name"]
        output["value"] = param["value"]
        res.write output.to_json
      end

      on "#{HOSTNAME}/kaya/api/custom/params/:name" do |name|
        output = {}
        param = Kaya::API::CustomParams.get(name)
        output["custom_param"] = param
        output["app"] = Kaya::Support::Configuration.project_name
        res.write output.to_json
      end

      on "#{HOSTNAME}/kaya/api/custom/params" do
        output ={}
        output["custom_params"] = Kaya::API::CustomParams.list()
        output["request"]="Custom Params"
        output["app"]=Kaya::Support::Configuration.project_name
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

      on "#{HOSTNAME}/kaya/error" do
        args= {query_string:Kaya::Support::QueryString.new(req), exception:nil}
        template = Mote.parse(File.read("#{Kaya::View.path}/error_handler.mote"),self, [:args])
        res.write template.call(args:args)
      end


# ========================================================================
# CLEAN
#
#
      on "#{HOSTNAME}/kaya/clean" do
        Kaya::Support::Clean.start
        res.redirect "/#{HOSTNAME}/kaya/tasks?msg=Tasks and results cleanned"
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

      on "#{HOSTNAME}/kaya/version" do
        res.redirect "#{HOSTNAME}/kaya/api/version"
      end

      on "#{HOSTNAME}/kaya/:any" do
          res.redirect("/#{HOSTNAME}/kaya/tests")
      end

      on "#{HOSTNAME}/kaya" do
        res.redirect "/#{HOSTNAME}/kaya/tasks"
      end

      on "favicon" do
        res.write ""
      end

      on "#{HOSTNAME}" do
        res.redirect "/#{HOSTNAME}/kaya/tasks"
      end

      on root do
        res.write "Check the url"
      end
    end



  rescue => e
    $K_LOG.error "Cuba: #{e} #{e.backtrace}" if $K_LOG
    args= {query_string:Kaya::Support::QueryString.new(req), exception:e}
    template = Mote.parse(File.read("#{Kaya::View.path}/error_handler.mote"),self, [:args])
    res.write template.call(args:args)
  end
end