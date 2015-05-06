require 'gmail'

module Kaya
  module Support
    class Notification

      include Gmail

      def initialize project_name, base_url=nil
        @project_name = project_name
        @base_url = base_url
        @subject_prefix = "[Kaya] [#{@project_name}] "
        if Kaya::Support::Configuration.notification?
          begin
            @email = Gmail.connect!(Kaya::Support::Configuration.notification_username,Kaya::Support::Configuration.notification_password)
            $K_LOG.debug "Notification: Login to Gmail Succesfully"
            $K_LOG.debug "Notification: USING NOTIFICATION TO #{Kaya::Support::Configuration.recipients}"
          rescue => e
            $K_LOG.error "Notification: ERROR TO CONNECT TO GMAIL #{e}".red
            $K_LOG.error "Notification: Connecting to GMail error => #{e}"
            @email = NoEmail.new
          end
        else
          @email = NoEmail.new
        end

      end

      def notificate subject, body
        send_email subject, body, Kaya::Support::Configuration.notifications_to
      end

      def send_email message_subject, message_body, path_to_file=nil
        message_subject = "#{@subject_prefix} #{message_subject}"
        begin
          email = @email.compose do
            to Kaya::Support::Configuration.recipients
            subject message_subject
            text_part do
              body message_body
            end
            html_part do
              $K_LOG.debug "Notification: Attaching report file (#{path_to_file})"
              content_type 'text/html; charset=UTF-8'
              body "<p>#{message_body}</p>"
            end
            add_file path_to_file
          end
          email.deliver!
          $K_LOG.debug "Notification: Email sent to (#{Kaya::Support::Configuration.recipients}) | Subject: '#{message_subject}' | Message: #{message_body}" if $K_LOG
        rescue => e
          $K_LOG.error "Notification: Could not sent email to (#{Kaya::Support::Configuration.recipients}) | Subject: '#{message_subject}' | Message: #{message_body} | #{e}\n #{e.backtrace}" if $K_LOG
        end

        if path_to_file
          begin
            File.delete path_to_file
            $K_LOG.debug "Notification: File #{path_to_file} deleted"
          rescue
            $K_LOG.error "Notification: Could not delete file #{path_to_file}"
          end
        end
      end



      def execution_finished result
        body = "
    Result Summary: #{result.summary}

    Command: #{result.command}

    Execution name: #{result.execution_name}

    Started at: #{result.started_at_formatted}

    Finished at: #{result.finished_at_formatted}

    Elapsed Time: #{result.elapsed_time} seconds

    Custom Params: #{result.custom_params}

    See log at http://#{@base_url}/kaya/results/#{result.id}/log"

        if Kaya::Support::Configuration.attach_report?
          path_to_file = "#{Dir.pwd}/kaya/temp/#{result.id}.html"
          $K_LOG.debug "Notification: Creating file report to attach to mail (#{path_to_file})"
          File.open("#{path_to_file}","a+"){|f| f.write result.html_report}
          $K_LOG.debug "Notification: File created (#{path_to_file})"
        end
        message_subject = "Execution Finished (#{result.id}) "
        send_email message_subject, body, path_to_file
      end

      def execution_stopped result, additional_text=nil
        body = "Execution stopped \n#{additional_text}"
        message_subject = "Execution stopped (#{result.id})"
        send_email message_subject, body
      end
    end

    class NoEmail

      def initialize

      end

      def method_missing meth, *args
        begin
        rescue
          $K_LOG.error "Notification: #{meth} invoked but email is not configured"
        end
      end

    end
  end
end
