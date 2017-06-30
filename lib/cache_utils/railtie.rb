require 'cache_utils/controller'
require 'cache_utils/model'
module CacheUtils
  class Railtie < Rails::Railtie
    initializer 'cache_utils.action_controller' do
      ActiveSupport.on_load(:action_controller) do
        # ActionController::Base gets a method that allows controllers to include the new behavior
        ActionController::API.send :include, CacheUtils::Controller # ActiveSupport::Concern
      end
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.send :include, CacheUtils::Model
      end
    end
  end
end
