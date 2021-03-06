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
      class_keys = self.class.cache_key
      class_keys += extra_class_key if respond_to?(:extra_class_key)
      redisw = $redisw || $redis
      redisr = $redisr || $redis
      keys = (redisr.scan_each(match: custom_cache_key + '*').to_a + redisr.scan_each(match: class_keys + '*').to_a)
      unless keys.empty?
        redisw.del(*keys)
        Appsignal.increment_counter('cache_purge', 1) if defined?(Appsignal)
      end
    end
  end
end
