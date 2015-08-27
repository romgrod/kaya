module Kaya
  module Tasks
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

        def self.all_required_ids
          Kaya::Database::MongoConnector.required_params_ids
        end

      end
    end
  end
end