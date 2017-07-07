module CacheUtils
  module Model
    extend ActiveSupport::Concern

    module ClassMethods
      def cache_key
        to_s.underscore.pluralize + '/index'
      end
    end

    included do
      after_save :purge_cache
    end

    def custom_cache_key
      self.class.to_s.underscore.pluralize + "/#{id}"
    end

    def purge_cache
      Rails.cache.data.del(*(Rails.cache.data.keys(custom_cache_key) + [self.class.cache_key]))
    end
  end
end
