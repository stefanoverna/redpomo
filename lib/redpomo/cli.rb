require 'thor'
require 'logger'

module Redpomo
  class CLI < ::Thor

    desc "pull", "imports Redmine open issues into local todo.txt"
    method_option :config, aliases: "-c", default: '~/.redpomo'
    def import
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


  end
end
