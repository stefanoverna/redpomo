require 'thor'

require 'redpomo/config'
require 'redpomo/task_list'
require 'redpomo/entry'
require 'redpomo/entries_printer'
require 'redpomo/fuzzy_converter'
require 'redpomo/config_generator'

module Redpomo
  class CLI < ::Thor
    map "p" => :pull
    map "o" => :open
    map "c" => :close

    desc "pull", "imports Redmine open issues into local todo.txt"
    method_option :config, aliases: "-c", default: '~/.redpomo'
    def pull
      configure!
      TaskList.pull_from_trackers!
    end

    desc "push LOGFILE", "parses Pomodoro export file and imports to Redmine clients"
    method_option :config, aliases: "-c", default: '~/.redpomo'
    method_option :fuzzy,  aliases: "-f", type: :boolean
    method_option :dry_run, aliases: "-n", type: :boolean
    def push(path)
      configure!

      entries = Entry.load_from_csv(path)
      entries = FuzzyConverter.convert(entries) if @options[:fuzzy]

      unless @options[:dry_run]
        entries.each(&:push!)
      end

      EntriesPrinter.print(entries)
    end

    desc "open TASK", "opens up the Redmine issue page of the selected task"
    method_option :config, aliases: "-c", default: '~/.redpomo'
    def open(task_number)
      configure!

      task = TaskList.find(task_number)
      task.open_in_browser!
    end

    desc "start TASK", "starts a Pomodoro session for the selected task"
    method_option :config, aliases: "-c", default: '~/.redpomo'
    def start(task_number)
      configure!

      task = TaskList.find(task_number)
      task.start_pomodoro!
    end

    desc "close TASK", "marks a todo.txt task as complete, and closes the related Redmine issue"
    method_option :config, aliases: "-c", default: '~/.redpomo'
    method_option :message, aliases: "-m"
    def close(task_number)
      configure!

      task = TaskList.find(task_number)
      task.done!
      task.close_issue!
    end

    desc "init", "generates a .redpomo configuration file on your home directory"
    method_option :path, aliases: "-p", default: '~/.redpomo'
    def init
      ConfigGenerator.start([ @options[:path] ])
    end

    private

    def configure!
      Config.load_from_yaml(@options[:config])
    end

  end
end
