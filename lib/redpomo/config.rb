require 'redpomo/tracker'

module Redpomo
  class Config

    def initialize(path)
      @data = YAML::load_file(File.expand_path(path))
    end

    def todo_path
      File.expand_path(@data["todo"])
    end

    def tasks
      @tasks ||= Todo::List.new(todo_path)
    end

    def trackers
      @trackers ||= @data["trackers"].map do |key, data|
        Tracker.new(key, data["url"], data["token"], data["default_project"])
      end
    end

    def tracker_for_task(task)
      trackers.find do |tracker|
        task.contexts.include? tracker.context
      end
    end

    def issues
      [].tap do |issues|
        trackers.each do |tracker|
          issues << tracker.issues
        end
      end.flatten
    end

  end
end
