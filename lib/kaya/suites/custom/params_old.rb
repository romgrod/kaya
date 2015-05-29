module Kaya
  module Suites
    module Custom
      class Params

        attr_reader :params

        # This class provides methods related to custom params
        # This is useful to ask about each params and its attributes

        # It receives plain string with the definitions of each custom param
        # @param [String] custom secion:
        #        a_text_field_param, required_text_param:*, with_a_default_value:foobar, required_and_with_default:foobar:* , a_select_list:[value1|value2|value3]
        #
        #  Text fields examples
        #
        #        'a_text_field_param'                                   -> will be interpreted as a text field accepting any value
        #        'required_text_param:*'                                -> will be interpreted as a text field with a required value (* indicates required field)
        #        'with_a_default_value:foobar'                          -> will be interpreted as a text field with a default value
        #        'required_and_with_default:foobar:*'                   -> will be interpreted as a text field with a default value and as a required field
        #
        #  Select list examples
        #        'a_select_list:(value1|value2|value3)'                 -> will be interpreted as a select list with listed values. First is used as default value
        #        'none_default_select_list:(none|value1|value2|value3)' -> will be interpreted as a select list with listed values. First is used as default value and none indicates as empty value
        #

        def initialize custom_params_definition
          if custom_params_definition
            plain_params = custom_params_definition.gsub(/\s+,/,",").gsub(/\,\s+/,",").split(",")
            @params = plain_params.map do |param|
              send(type_of(param), param)
            end
          else
            @params = {}
          end
          @params
        end


        # Returns the type of the parameter according to its structure
        def type_of entire_param
          parts = entire_param.split(":")

          if parts.last =~ /^\(.*\)$/ # It is a select list

            "select_list"

          else # It is a text field

            case parts.size

            when 1
              "single_text_field"

            when 2
              return "required_text_field" if parts.last == "*"
              "default_text_field"

            when 3
              if parts.last == "*"
                "required_default_text_field"
              else
                raise "Malformed custom param"
              end
            end
          end

        end

        # Returns the structure of a select list element
        # @param [String] the plain structure of a custom param
        # @return [Hash] a hash with the required structure
        def select_list param
          plus = Hash.new
          name, values = param.split(":")
          values.gsub!(/\(|\)/, "")
          values = values.split("|").map do |val|
            if val.include? "*"
              h = val.split("*")
              plus[h[0]] = h[1]
              val = h[0]
            end
            val
          end
          {
            "name" => name,
            "type" => "select_list",
            "options" => values,
            "plus_options" => plus,
            "required" => nil,
            "value" => nil
          }
        end

        # Returns the structure of a single text field
        # @param [String] the plain structure of a custom param
        # @return [Hash] a hash with the required structure
        def single_text_field param
          {
            "name" => param.split.first,
            "type" => "text",
            "options" => nil,
            "required" => nil,
            "value" => nil
          }
        end

        # Returns the structure of a required text field
        # @param [String] the plain structure of a custom param
        # @return [Hash] a hash with the required structure
        def required_text_field param
          {
            "name" => param.split(":").first,
            "type" => "text",
            "options" => nil,
            "required" => true,
            "value" => nil
          }
        end

        # Returns the structure of a text field with a default value
        # @param [String] the plain structure of a custom param
        # @return [Hash] a hash with the required structure
        def default_text_field param
          name, value = param.split ":"
          {
            "name" => name,
            "type" => "text",
            "options" => value,
            "required" => false,
            "value" => nil
          }
        end

        # Returns the structure of a text field with a default value and required
        # @param [String] the plain structure of a custom param
        # @return [Hash] a hash with the required structure
        def required_default_text_field param
          name, value= param.split(":")
          {
            "name" => name,
            "type" => "text",
            "options" => value,
            "required" => true,
            "value" => nil
          }
        end
      end
    end
  end
end
