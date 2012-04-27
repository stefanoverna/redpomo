require 'thor'
require 'logger'

module Redpomo
  class CLI < ::Thor

    desc "pull", "imports Redmine open issues into local todo.txt"
    method_option :config, aliases: "-c", default: '~/.redpomo'
    def pull
      require 'redpomo/puller'
      Redpomo::Puller.new(options).execute
    end

    desc "push LOGFILE", "parses Pomodoro export file and imports to Redmine clients"
    method_option :config, aliases: "-c", default: '~/.redpomo'
    method_option :fuzzy,  aliases: "-f", type: :boolean
    def push(path)
      require 'redpomo/pusher'
      Redpomo::Pusher.new(path, options).execute
    end

    desc "open TASK", "opens up the Redmine issue pagei of the selected task"
    method_option :config, aliases: "-c", default: '~/.redpomo'
    def open(task_number)
      require 'redpomo/opener'
      Redpomo::Opener.new(task_number, options).open
    end

    desc "start TASK", "starts a Pomodoro session for the selected task"
    method_option :config, aliases: "-c", default: '~/.redpomo'
    def start(task_number)
      require 'redpomo/opener'
      Redpomo::Opener.new(task_number, options).start
    end

  end
end
