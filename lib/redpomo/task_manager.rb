require 'redpomo/config'

module Redpomo
  class TaskManager

    def initialize(task_number, options)
      @task_number = task_number.to_i
      @options = options
    end

    def open
      task = config.tasks[@task_number-1]
      tracker = config.tracker_for_task(task)
      Launchy.open(tracker.url_for(task))
    end

    def start
      task = config.tasks[@task_number-1]
      tracker = config.tracker_for_task(task)
      command = 'tell application "Pomodoro" to start "'
      command << task.orig
      command << '"'
      AppleScript.execute(command)
    end

    def close
      task = config.tasks[@task_number-1]
      tasks = Todo::List.new(config.tasks - [ task ])
      tracker = config.tracker_for_task(task)
      task.issues.each do |issue|
        issue = issue.gsub(/^#/, '')
        tracker.close_issue(issue, @options[:message])
      end
      tasks.write_to(config.todo_path)
    end

    private

    def config
      @config ||= Redpomo::Config.new(@options[:config])
    end

  end
end
