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
        Rails.cache.fetch(name, options, &block)
      else
        yield
      end
    end

    def render_with_cache(object, condition, name = {}, options = nil)
      render jsonapi: cache_if(condition, name, options) {
                        ActiveModelSerializers::SerializableResource.new(object).to_json
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

def serialize_hash(hash)
  hash.to_a.sort_by { |k, _v| k.to_s }.map do |k, v|
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
  end.flatten.join('.')
end