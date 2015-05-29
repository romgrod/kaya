module Kaya
  module Suites
    module Custom
      module Params
        def self.list
          Kaya::API::CustomParams.list
        end

        def self.param_name_exist? name
          Kaya::Database::MongoConnector.exist_custom_param_name? name
        end

        def self.exist? param_id
          Kaya::Database::MongoConnector.exist_custom_param_id? param_id
        end

      end
    end
  end
end