module Kaya
  module View
    class Sections

      @@sections = {
        "Edit Tasks" => "tasks/admin/list",
        "Add Task" => "tasks/admin/new",
        "Edit Task" => "tasks/admin/edit",
        "Delete Task" => "tasks/admin/delete",
        "Tests" => "tasks/tasks",
        "Test Message" => 'tasks/message',
        "Tasks" => "tasks/tasks",
        "Task Message" => 'tasks/message',
        "Features" => "features/features",
        "Feature" => "features/feature",
        "Results"=>  "results/results",
        "Console" => "results/console",
        "Report" => "results/report",
        "All Results"=> "results/all",
        "Custom Params" => "custom/params/list",
        "New Custom Param" => "custom/params/new",
        "Edit Custom Param" => "custom/params/edit",
        "Delete Custom Param" => "custom/params/delete",
        "Repo" => "",
        "Logs" => "logs",
        "Log" => "logs/log",
        "Help" => ""
      }

      def self.path_for section
        @@sections[section]
      end


    end
  end
end