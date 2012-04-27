require 'redpomo/config'

module Redpomo
  class Puller

    def initialize(options = {})
      @options = options
    end

    def execute
      list = Todo::List.new(
        config.issues.map(&:to_task) +
        unrelated_tasks
      )
      list.write_to(config.todo_path)
    end

    private

    def config
      @config ||= Redpomo::Config.new(@options[:config])
    end

    def trackers_contexts
      @trackers_context ||= config.trackers.map(&:context)
    end

    def unrelated_tasks
      config.tasks.select do |task|
        ! task.include_contexts?(trackers_contexts)
      end
    end

  end
end
