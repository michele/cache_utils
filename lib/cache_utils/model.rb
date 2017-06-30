module CacheUtils
  module Model
    extend ActiveSupport::Concern

    module ClassMethods
      def cache_key
        to_s.pluralize.underscore + '/index'
      end
    end

    included do
      after_save :purge_cache
    end

    def purge_cache
      Rails.cache.data.del(*(Rails.cache.data.keys(cache_key) + [self.class.cache_key]))
    end
  end
end
