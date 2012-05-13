require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/hash'
require 'yaml'

require 'redpomo/file_cache'
require 'redpomo/null_cache'

module Redpomo
  module Config

    mattr_reader :todo_path, :trackers_data, :cache

    @@cache = NullCache

    def self.load_from_yaml(path)
      config_path = File.expand_path(path)
      data = YAML::load_file(config_path)

      @@todo_path = File.expand_path(data["todo"], File.dirname(config_path))
      @@trackers_data = data["trackers"].symbolize_keys!
      @@cache = data["cache"] ? FileCache : NullCache
    end

  end
end
