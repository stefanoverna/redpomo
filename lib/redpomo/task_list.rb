require 'todo'
require 'redpomo/task'

module Redpomo
  class TaskList < Array

    def self.find(task_number)
      list = TaskList.new(Config.todo_path)
      list.find(task_number)
    end

    def self.pull_from_trackers!
      list = TaskList.new(Config.todo_path)
      list.pull_from_trackers!
    end

    def self.add!(task)
      list = TaskList.new(Config.todo_path)
      list.add!(task)
    end

    def initialize(path)
      @path = path
      File.read(path).split("\n").each do |line|
        push Task.new(self, line)
      end
    end

    def find(task_number)
      slice(task_number.to_i - 1)
    end

    def remove!(task)
      delete(task)
      write!
    end

    def add!(task)
      push task
      write!
    end

    def pull_from_trackers!
      issue_tasks = Tracker.all.map(&:issues).flatten.map(&:to_task)
      delete_if do |task|
        task.tracker.present?
      end
      self << issue_tasks
      self.flatten!
      write!
      Redpomo.ui.info "Pulled #{issue_tasks.count} issues."
    end

    def write!
      File.open(@path, 'w') do |file|
        file.write map(&:orig).join("\n") + "\n"
      end
    end

  end
end
