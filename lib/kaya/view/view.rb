module Kaya
  module View

    def self.path
      File.expand_path('../', __FILE__)
    end

    def self.label_color_for result
      if result["summary"]
        label_color = color result["summary"]
        "<a class='label label-#{label_color}' #{access_report?(result)}>#{result['summary'].capitalize}</a>"
      else
        "<a href='#' class='label label-default' >No summary</a>"
      end
    end

    def self.only_label_for result
      label_color = color result["summary"]
      "<div class='label label-#{label_color}'>#{result['summary'].capitalize}</div>"
    end

    def self.color value
      case value.downcase
        when /running/
          "success"
        when /finished|ready/
          "primary"
        when /(stopped|failed)/
          "danger"
        when /\d+ scenarios? \(\d+ pending\).*\d+ steps?/
          "warning"
        when /\d+ scenarios? \(\d+ passed\).*\d+ steps?/
          "success"
        when /\d+ scenarios? \(\d+ failed\).*\d+ steps?/
          "danger"
        when /(undefined|pending)/
          "warning"
        else
          "default"
      end
    end

    def self.unviewed
      '<span class="glyphicon glyphicon-eye-open" aria-hidden="true"></span>'
    end

    def self.access_report? result
      if result["status"] =~ /stopped|running/
        "onclick=\"javascript:refreshAndOpen('/#{Kaya::Support::Configuration.hostname}/kaya/results/log/#{result["_id"]}');\""
      else
        "onclick=\"javascript:refreshAndOpen('/#{Kaya::Support::Configuration.hostname}/kaya/results/report/#{result['_id']}');\"" if result["status"]=='finished' and result["has_report"]
      end
    end

    def self.label_color_for_result_id result_id
      result = Kaya::API::Result.info result_id
      self.label_color_for result if result
    end

    def self.formatted_for seconds
      hours     = seconds/ 3600
      seconds   = seconds% 3600
      minutes   = seconds/ 60
      seconds   = seconds % 60
      elapsed   = ""
      elapsed  += "#{hours} h " if hours > 0
      elapsed  += " #{minutes} m " if minutes > 0
      elapsed  += "#{seconds} s" if seconds
      "#{elapsed}"
    end

    def self.result_started_at result_id
      result = Kaya::API::Result.info result_id
      self.formatted_for result["started_at"] if result
    end
  end
end