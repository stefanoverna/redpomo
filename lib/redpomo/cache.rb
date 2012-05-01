require 'singleton'

module Redpomo
  module Cache

    def self.get(key, &block)
      Cacher.instance.get(key, &block)
    end

    class Cacher
      include Singleton

      def get(key, &block)
        return existing_keys[key] if existing_keys.has_key?(key)
        if block_given?
          value = block.call
          set(key, value)
          value
        end
      end

      private

      def existing_keys
        File.exists?(cache_path) ? YAML::load_file(cache_path) : {}
      end

      def set(key, val)
        dict = existing_keys
        dict[key] = val
        File.open(cache_path, 'w') { |f| f.write(dict.to_yaml) }
      end

      def cache_path
        File.expand_path("~/.redpomo-cache~")
      end
    end

  end
end
