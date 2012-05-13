require 'thor'
require 'tempfile'

require 'redpomo/config'
require 'redpomo/task_list'
require 'redpomo/entry'
require 'redpomo/entries_printer'
require 'redpomo/fuzzy_converter'
# require 'redpomo/issue_generator'

module Redpomo
  class CLI < ::Thor
    include Thor::Actions

    def initialize(*)
      super
      the_shell = (options["no-color"] ? Thor::Shell::Basic.new : shell)
      Redpomo.ui = UI::Shell.new(the_shell)
      configure!
    end

    default_task :pull
    class_option "config", :aliases => "-c", default: '~/.redpomo'
    class_option "no-color", :type => :boolean

    map "o" => :open
    map "c" => :close
    map "a" => :add

    desc "add", "creates a new task on Todo.txt, forwarding it to the remote tracker"
    method_option :description, aliases: "-d"
    def add(subject = nil)
      description = @options[:description]

      if subject.blank?
        message_path = Tempfile.new('issue').path + ".textile"
        template "issue_stub.textile", message_path, verbose: false
        subject, description = parse_message edit(message_path)
      end

      issue = Task.new(nil, subject).to_issue
      issue.description = description
      issue.create!

      Redpomo.ui.info "Issue created, see it at #{issue.to_task.url}"
    end

    desc "pull", "imports Redmine open issues into local todo.txt"
    def pull
      TaskList.pull_from_trackers!
    end

    desc "push LOGFILE", "parses Pomodoro export file and imports to Redmine clients"
    method_option :fuzzy,  aliases: "-f", type: :boolean
    method_option :dry_run, aliases: "-n", type: :boolean
    def push(path)
      entries = Entry.load_from_csv(path)
      entries = FuzzyConverter.convert(entries) if @options[:fuzzy]

      unless @options[:dry_run]
        entries.each(&:push!)
        Redpomo.ui.info "Pushed #{entries.count} time entries!"
      end

      EntriesPrinter.print(entries)
    end

    desc "open TASK", "opens up the Redmine issue page of the selected task"
    def open(task_number)
      task = TaskList.find(task_number)
      task.open_in_browser!
    end

    desc "start TASK", "starts a Pomodoro session for the selected task"
    def start(task_number)
      task = TaskList.find(task_number)
      task.start_pomodoro!
    end

    desc "close TASK", "marks a todo.txt task as complete, and closes the related Redmine issue"
    method_option :message, aliases: "-m"
    def close(task_number)
      task = TaskList.find(task_number)
      task.done!
      task.close_issue!

      Redpomo.ui.info "Issue updated, see it at #{task.url}"
    end

    desc "init", "generates a .redpomo configuration file on your home directory"
    def init(path = '~/.redpomo')
      path =  File.expand_path(path)
      template "config.yml", path, verbose: false

      editor = [ENV['REDPOMO_EDITOR'], ENV['VISUAL'], ENV['EDITOR']].find{|e| !e.nil? && !e.empty? }
      if editor
        command = "#{editor} #{path}"
        system(command)
        File.read(path)
      else
        Redpomo.ui.info("To open the .redpomo config file, set $EDITOR or $REDPOMO_EDITOR")
      end
    end

    private

    def configure!
      Config.load_from_yaml(options["config"])
    end

    def self.source_root
      File.dirname(__FILE__) + "/templates"
    end

    def parse_message(message)
      # remove comments
      message.gsub! /#.*$/, ''
      # remove empty lines at beginning of string
      message.gsub! /\A\n*/, ''

      # first line is the subject, the rest is description
      subject, description = message.split(/\n/, 2)

      subject ||= ''
      description ||= ''

      [subject.strip, description.strip]
    end

  end
end
