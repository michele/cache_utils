module CacheUtils
  module Controller
    extend ActiveSupport::Concern

    def cache_bundle(*objects)
      objects.map { |o| cache_key_for(o) }.join(':')
    end

    def cache_key_for(object)
      if object.respond_to?(:cache_key)
        object.cache_key
      elsif object.is_a?(Hash)
        serialize_hash(object)
      else
        object.to_s
      end
    end

    def cache_if(condition, name = {}, options = nil, &block)
      if condition
        fetch_cache(name, options, &block)
      else
        yield
      end
    end

    def get_cache(key)
      cached = $redis.get(key)
      if cached
        Appsignal.increment_counter('cache_hit', 1) if defined?(Appsignal)
        return cached
      end
      Appsignal.increment_counter('cache_miss', 1) if defined?(Appsignal)
      nil
    end

    def set_cache(key, content)
      $redis.set(key, content)
    end

    def fetch_cache(key, _options = nil)
      cached = $redis.get(key)
      if cached
        Appsignal.increment_counter('cache_hit', 1) if defined?(Appsignal)
        return cached
      end
      Appsignal.increment_counter('cache_miss', 1) if defined?(Appsignal)
      if block_given?
        fresh = yield
        $redis.set(key, fresh)
        fresh
      end
    end

    def serialize_for_cache(object, options = {})
      ActiveModelSerializers::SerializableResource.new(object, options)
    end

    def render_with_cache(object, condition, name = {}, options = nil)
      render jsonapi: cache_if(condition, name, options) {
                        serialize_for_cache(object)
                      }, raw: true
    end

    private

    def serialize_hash(hash)
      Digest::MD5.hexdigest(hash.to_a.sort_by { |k, _v| k.to_s }.map do |k, v|
        val = if v.is_a?(Hash)
                serialize_hash(v)
              elsif v.is_a?(Array)
                v.map(&:to_s).sort
              elsif v.respond_to?(:cache_key)
                v.cache_key
              else
                v.to_s
      end
        [k, val]
      end.flatten.join('.'))
    end
  end
end
