require 'singleton'
require 'redpomo/config'

module Redpomo
  class FileCache

    include Singleton
    attr_accessor :cache_path

    def self.get(key, &block)
      instance.get(key, &block)
    end

    def get(key, &block)
      return existing_keys[key] if existing_keys.has_key?(key)
      if block_given?
        value = block.call
        set(key, value)
        value
      end
    end

    private

    def initialize
      @cache_path = File.expand_path("~/.redpomo-cache~")
    end

    def existing_keys
      if File.exists?(cache_path)
        YAML::load_file(cache_path) || {}
      else
        {}
      end
    end

    def set(key, val)
      dict = existing_keys
      dict[key] = val
      File.open(cache_path, 'w') { |f| f.write(dict.to_yaml) }
    end

  end
end
