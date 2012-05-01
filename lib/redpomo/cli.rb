require 'thor'

module Redpomo
  class CLI < ::Thor

    desc "pull", "imports Redmine open issues into local todo.txt"
    method_option :config, aliases: "-c", default: '~/.redpomo'
    method_option :refresh, aliases: "-r", type: :boolean
    def pull
      require 'redpomo/puller'
      Redpomo::Puller.new(options).execute
    end

    desc "push LOGFILE", "parses Pomodoro export file and imports to Redmine clients"
    method_option :config, aliases: "-c", default: '~/.redpomo'
    method_option :fuzzy,  aliases: "-f", type: :boolean
    method_option :dry_run, aliases: "-n", type: :boolean
    def push(path)
      require 'redpomo/pusher'
      Redpomo::Pusher.new(path, options).execute
    end

    desc "open TASK", "opens up the Redmine issue page of the selected task"
    method_option :config, aliases: "-c", default: '~/.redpomo'
    def open(task_number)
      require 'redpomo/task_manager'
      Redpomo::TaskManager.new(task_number, options).open
    end

    desc "start TASK", "starts a Pomodoro session for the selected task"
    method_option :config, aliases: "-c", default: '~/.redpomo'
    def start(task_number)
      require 'redpomo/task_manager'
      Redpomo::TaskManager.new(task_number, options).start
    end

    desc "close TASK", "marks a todo.txt task as complete, and closes the related Redmine issue"
    method_option :config, aliases: "-c", default: '~/.redpomo'
    method_option :message, aliases: "-m"
    def close(task_number)
      require 'redpomo/task_manager'
      Redpomo::TaskManager.new(task_number, options).close
    end

  end
end
