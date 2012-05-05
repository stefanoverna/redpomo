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
      data = YAML::load_file(File.expand_path(path))

      @@todo_path = File.expand_path(data["todo"])
      @@trackers_data = data["trackers"].symbolize_keys!
      @@cache = data["cache"] ? FileCache : NullCache
    end

    # def todo_path
    #   File.expand_path(@data["todo"])
    # end

    # def tasks
    #   @tasks ||= Todo::List.new(todo_path)
    # end

    # def find_task(number)
    #   tasks[number.to_i - 1]
    # end

    # def trackers
    #   @trackers ||= @data["trackers"].map do |key, data|
    #     Tracker.new(data.merge(name: key))
    #   end
    # end

    # def issues
    #   [].tap do |issues|
    #     trackers.each do |tracker|
    #       issues << tracker.issues
    #     end
    #   end.flatten
    # end

  end
end
