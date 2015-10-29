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

    $K_LOG.debug "APP_NAME:#{APP_NAME = Kaya::Support::Configuration.hostname}"

    on post do

      on "#{APP_NAME}/kaya/admin/reload" do
        on true do

          # Guarda el nuevo archivo de configuración si es válido

          Kaya::Support::Configuration.get
        end
      end

      on "#{APP_NAME}/kaya/admin/delete-custom-param" do

        on true do

          data = req.params.dup

          data["_id"] = data["_id"].to_i

          response = Kaya::API::CustomParams.set data # Creates or update

          path = "/#{APP_NAME}/kaya/admin/custom/params"
          path += "?msg=#{response[:message]}" if response[:message]

          res.redirect path
        end

      end

      # TO EDIT OR CREATE CUSTOM PARAM
      on "#{APP_NAME}/kaya/admin/custom-param" do

        on true do

          data = req.params.dup

          $K_LOG.debug "data is => #{data}"

          response = Kaya::API::CustomParams.set data # Creates or update

          path = "/#{APP_NAME}/kaya/admin/custom/params"

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


      on "#{APP_NAME}/kaya/admin/tasks/add-edit" do

        on true do

          data = req.params.dup

          $K_LOG.debug "#{data['action']} Task - Recieved data => #{data}"

          # Extracts custom params
          custom_params = data.keys.select{|field| field.start_with? "custom_param_" and data.delete(field)}.inject([]){|res, value| res<<value.gsub("custom_param_","").to_i; res}

          data["custom_params"] = custom_params

          $K_LOG.debug "DATA SENT TO Task.set is => #{data}"

          response = Kaya::API::Tasks.set data # Creates or update

          path = "/#{APP_NAME}/kaya/admin/tasks"

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

      on "#{APP_NAME}/kaya/admin/tasks/delete" do

        on true do

          data = req.params.dup

          $K_LOG.debug "DATA SENT TO Task.delete is => #{data}"

          result = Kaya::Tasks.delete! data["task_id"]
          path = "/#{APP_NAME}/kaya/admin/tasks/list"

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
      on "#{APP_NAME}/kaya/help/:page" do |page|
        args ={page:page}
        template = Mote.parse(File.read("#{Kaya::View.path}/help.mote"),self, [:args])
        res.write template.call(:args => args)
      end

      on "#{APP_NAME}/kaya/help" do
        res.redirect "/#{APP_NAME}/kaya/help/main"
      end


# ========================================================================
# VIEW ROUTES
#
#
#
      # INVERTIR /log con  /:result_id

      on "#{APP_NAME}/kaya/results/:result_id/log" do |result_id|
        # result = Kaya::Results::Result.get(result_id)
        # res.redirect "/#{APP_NAME}/kaya/404/There%20is%20no%20result%20for%20id=#{result_id}" if result.nil?
        # result.mark_as_saw! if (result.finished? or result.stopped?)
        template = Mote.parse(File.read("#{Kaya::View.path}/results/console.mote"),self, [:result_id])
        res.write template.call(result_id:result_id)
      end


      # INVERTIR /log con  /:result_id
      on "#{APP_NAME}/kaya/results/report/:result_id" do |result_id|
        result = Kaya::Results::Result.get(result_id)
        res.redirect "/#{APP_NAME}/kaya/404/There%20is%20no%20result%20for%20id=#{result_id}" if result.nil?
        result.mark_as_saw! if (result.finished? or result.stopped?)
        if result.finished? and !result.stopped? and result.html_report.size > 0
          template = Mote.parse(File.read("#{Kaya::View.path}/results/report.mote"),self, [:result])
          res.write template.call(result:result)
        else
          res.redirect "#{APP_NAME}/kaya/results/#{result_id}/log"
        end
      end

      on "#{APP_NAME}/kaya/results/:result_id/reset" do |result_id|
        result = Kaya::API::Execution.reset(result_id)
        res.redirect "/#{APP_NAME}/kaya/results?msg=#{result['message']}"
      end

      on "#{APP_NAME}/kaya/results/task/:task_name" do |task_name|
        query_string = Kaya::Support::QueryString.new req
        task_name.gsub!("%20"," ")
        args = {task_name:task_name, query_string:query_string}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Results", args:args)
      end

      on "#{APP_NAME}/kaya/results/all" do
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"All Results", args:args)
      end

      on "#{APP_NAME}/kaya/results" do
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

      on "#{APP_NAME}/kaya/admin/tasks/list" do
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Edit Tasks", args:{:query_string => Kaya::Support::QueryString.new(req)})
      end


      on "#{APP_NAME}/kaya/admin/tasks/new" do
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string, action:"new"}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Add Task", args:args)
      end

      on "#{APP_NAME}/kaya/admin/tasks/:task_id/edit" do |task_id|
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string, action:"edit"}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Edit Task", args:args)

      end

      on "#{APP_NAME}/kaya/admin/tasks/:task_id/delete" do |task_id|
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string, task_id:task_id}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Delete Task", args:args)
      end

      on "#{APP_NAME}/kaya/admin/tasks/:task_id/view" do |task_id|
        # query_string = Kaya::Support::QueryString.new req
        # args = {query_string:query_string}
        # template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        # res.write template.call(section:"Delete Task", args:args)
        res.write "VIEWING TASK WITH ID: #{task_id}"
      end

      on "#{APP_NAME}/kaya/admin/custom/params/new" do
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string, action:"new"}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"New Custom Param", args:args)
      end

      on "#{APP_NAME}/kaya/admin/custom/params/:custom_id/edit" do |custom_param_id|
        query_string = Kaya::Support::QueryString.new req
        res.redirect "/#{APP_NAME}/kaya/admin/custom/params?msg=Could not find Custom Parameter" if Kaya::Tasks::Custom::Params.exist? custom_param_id
        args = {query_string:query_string, custom_param_id:custom_param_id, action:"edit"}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Edit Custom Param", args:args)
      end

      on "#{APP_NAME}/kaya/admin/custom/params/:custom_id/delete" do |custom_param_id|
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string, custom_param_id:custom_param_id, action:"delete"}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Delete Custom Param", args:args)
      end

      on "#{APP_NAME}/kaya/admin/custom/params" do
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Custom Params", args:args)
      end

      on "#{APP_NAME}/kaya/admin/configuration" do
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Configuration", args:args)
      end




## ===============================================
# TASKS
#
#

      on "#{APP_NAME}/kaya/tasks/:task/run" do |task_name|
        query_string = Kaya::Support::QueryString.new req
        task_name.gsub!("%20"," ")
        result = Kaya::API::Execution.start task_name, query_string.values
        $K_LOG.debug "result => #{result}"
        path = if result["execution_id"]
         "/#{APP_NAME}/kaya/message/task/#{result['execution_id']}"
        else
          "/#{APP_NAME}/kaya/error?msg=#{result['message']}"
        end
        res.redirect path
      end


      on "#{APP_NAME}/kaya/message/task/:result_id" do |result_id|
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string, result_id:result_id}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Task Message", args:args)
      end


      on "#{APP_NAME}/kaya/tasks/:task_name" do |task_name|
        query_string = Kaya::Support::QueryString.new req
        task_name.gsub!("%20"," ")
        args = {query_string:query_string, task_name:task_name}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Tasks", args:args)
      end

      on "#{APP_NAME}/kaya/tasks" do
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

      on "#{APP_NAME}/kaya/tests/:task/run" do |task_name|
        query_string = Kaya::Support::QueryString.new req
        task_name.gsub!("%20"," ")
        result = Kaya::API::Execution.start task_name, query_string.values, "test"
        $K_LOG.debug "result => #{result}"
        path = if result["execution_id"]
         "/#{APP_NAME}/kaya/message/test/#{result['execution_id']}"
        else
          "/#{APP_NAME}/kaya/error?msg=#{result['message']}"
        end
        res.redirect path
      end

      on "#{APP_NAME}/kaya/message/test/:result_id" do |result_id|
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string, result_id:result_id}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Test Message", args:args)
      end

      on "#{APP_NAME}/kaya/tests/:task_name" do |task_name|
        query_string = Kaya::Support::QueryString.new req
        $K_LOG.debug "task_name => #{task_name}"
        task_name.gsub!("%20"," ")
        args = {query_string:query_string, task_name:task_name}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Tests", args:args)
      end

      on "#{APP_NAME}/kaya/tests" do
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Tests", args:args)
      end



## ========================================================================
# LOGS
#
#



      on "#{APP_NAME}/kaya/logs/:log_name" do |log_name|
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string, log_name:log_name}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Log", args:args)
      end

      on "#{APP_NAME}/kaya/logs" do
        query_string = Kaya::Support::QueryString.new req
        args = {query_string:query_string}
        template = Mote.parse(File.read("#{Kaya::View.path}/body.mote"),self, [:section, :args])
        res.write template.call(section:"Logs", args:args)
      end





# ========================================================================
# SCREENSHOTS
#
#

      on "#{APP_NAME}/kaya/screenshot/:file_name" do |file_name|
        template = Mote.parse(File.read("#{Kaya::View.path}/screenshot.mote"),self, [:file_name])
        res.write template.call(file_name:file_name)
      end

# ========================================================================
# FEATURE SHOW
#
#
      on "#{APP_NAME}/kaya/features/file" do
        template = Mote.parse(File.read("#{Kaya::View.path}/features.mote"),self, [:query_string])
        res.write template.call(query_string:Kaya::Support::QueryString.new(req))
      end

# ========================================================================
# FEATURES / LIST
#
#
      on "#{APP_NAME}/kaya/features" do
        template = Mote.parse(File.read("#{Kaya::View.path}/features.mote"),self, [:query_string])
        res.write template.call(query_string:Kaya::Support::QueryString.new(req))
      end


# ========================================================================
# API ROUTES
#
#
#
      on "#{APP_NAME}/kaya/api/version" do
        output = { "version" => Kaya::VERSION}
        res.write output.to_json
      end

      on "#{APP_NAME}/kaya/api/results/:id/data" do |result_id|
        query_string = Kaya::Support::QueryString.new req
        output = Kaya::API::Result.data(result_id, query_string.raw)
        res.write output.to_json
      end

      on "#{APP_NAME}/kaya/api/results/:id/status" do |result_id|
        output = Kaya::API::Result.status(result_id)
        res.write output.to_json
      end

      on "#{APP_NAME}/kaya/api/results/:id" do |result_id|
        res.write(Kaya::API::Result.info(result_id).to_json)
      end

      on "#{APP_NAME}/kaya/api/results/:id/reset" do |result_id|
        result = Kaya::API::Execution.reset(result_id)
        res.write result.to_json
      end

      on "#{APP_NAME}/kaya/api/tasks/:task/run" do |task_name|
        task_name.gsub!("%20"," ")
        query_string = Kaya::Support::QueryString.new req
        result = Kaya::API::Execution.start task_name, query_string.values
        res.write result.to_json
      end

      on "#{APP_NAME}/kaya/api/tests/:task/run" do |task_name|
        task_name.gsub!("%20"," ")
        query_string = Kaya::Support::QueryString.new req
        result = Kaya::API::Execution.start task_name, query_string.values
        res.write result.to_json
      end

      on "#{APP_NAME}/kaya/api/tasks/:id/status" do |task_id|
        output = Kaya::API::Task.status(task_id.to_i)
        res.write output.to_json
      end

      on "#{APP_NAME}/kaya/api/tests/:id/status" do |task_id|
        output = Kaya::API::Task.status(task_id.to_i)
        res.write output.to_json
      end

      on "#{APP_NAME}/kaya/api/tasks/running" do
        output = Kaya::API::Tasks.list({running:true, type:"task"})
        res.write output.to_json
      end

      on "#{APP_NAME}/kaya/api/tests/running" do
        output = Kaya::API::Tasks.list({running:true, type:"task"})
        res.write output.to_json
      end

      on "#{APP_NAME}/kaya/api/tasks/:id" do |task_id|
        output = Kaya::API::Task.info(task_id)
        res.write output.to_json
      end

      on "#{APP_NAME}/kaya/api/tests/:id" do |task_id|
        output = Kaya::API::Task.info(task_id)
        res.write output.to_json
      end

      on "#{APP_NAME}/kaya/api/tasks" do
        output = Kaya::API::Tasks.list({type:"task"})
        res.write output.to_json
      end

      on "#{APP_NAME}/kaya/api/tests" do
        output = Kaya::API::Tasks.list({type:"test"})
        res.write output.to_json
      end

      on "#{APP_NAME}/kaya/api/results" do
        output = Kaya::API::Results.show()
        res.write output.to_json
      end

      on "#{APP_NAME}/kaya/api/custom/params/:name/value" do |name|
        output = {}
        param = Kaya::API::CustomParams.get(name)
        output["app"] = Kaya::Support::Configuration.project_name
        output["request"] = "Custom Parameter value"
        output["custom_param_name"] = param["name"]
        output["value"] = param["value"]
        res.write output.to_json
      end

      on "#{APP_NAME}/kaya/api/custom/params/:name" do |name|
        output = {}
        param = Kaya::API::CustomParams.get(name)
        output["custom_param"] = param
        output["app"] = Kaya::Support::Configuration.project_name
        res.write output.to_json
      end

      on "#{APP_NAME}/kaya/api/custom/params" do
        output ={}
        output["custom_params"] = Kaya::API::CustomParams.list()
        output["request"]="Custom Params"
        output["app"]=Kaya::Support::Configuration.project_name
        res.write output.to_json
      end


      on "#{APP_NAME}/kaya/api/error" do
        query_string = Kaya::Support::QueryString.new req
        output = Kaya::API::Error.show(query_string)
        res.write output.to_json
      end

      on "#{APP_NAME}/kaya/api" do
        response = {"message" => "Please, refer to /#{APP_NAME}/kaya/help/api for more information"}
        res.write response.to_json
      end

      on "#{APP_NAME}/kaya/error" do
        args= {query_string:Kaya::Support::QueryString.new(req), exception:nil}
        template = Mote.parse(File.read("#{Kaya::View.path}/error_handler.mote"),self, [:args])
        res.write template.call(args:args)
      end


# ========================================================================
# CLEAN
#
#
      on "#{APP_NAME}/kaya/clean" do
        Kaya::Support::Clean.start
        res.redirect "/#{APP_NAME}/kaya/tasks?msg=Tasks and results cleanned"
      end

# ========================================================================
# REDIRECTS
#
      on "#{APP_NAME}/kaya/help" do
        res.redirect "/#{APP_NAME}/kaya/help/main"
      end

      on "#{APP_NAME}/kaya/404" do
        template = Mote.parse(File.read("#{Kaya::View.path}/not_found.mote"),self, [])
        res.write template.call()
      end

      on "#{APP_NAME}/kaya/version" do
        res.redirect "#{APP_NAME}/kaya/api/version"
      end

      on "#{APP_NAME}/kaya/:any" do
          res.redirect("/#{APP_NAME}/kaya/tests")
      end

      on "#{APP_NAME}/kaya" do
        res.redirect "/#{APP_NAME}/kaya/tasks"
      end

      on "favicon" do
        res.write ""
      end

      on "#{APP_NAME}" do
        res.redirect "/#{APP_NAME}/kaya/tasks"
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