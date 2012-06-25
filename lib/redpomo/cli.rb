require 'thor'
require 'tempfile'

require 'redpomo/config'
require 'redpomo/task_list'
require 'redpomo/entry'
require 'redpomo/entries_printer'
require 'redpomo/fuzzy_converter'

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

    desc "add [TASK]", "creates a new task on Todo.txt, forwarding it to the remote tracker"
    method_option :description, aliases: "-d"
    def add(subject = nil)
      description = @options[:description]

      if subject.blank?
        message_path = Tempfile.new('issue').path + ".textile"
        template "issue_stub.textile", message_path, verbose: false
        subject, description = parse_message open_editor(message_path)
      end

      issue = Task.new(nil, subject).to_issue
      issue.description = description

      if issue.tracker.present?
        issue.create!
        task = issue.to_task
        task.add!

        Redpomo.ui.info "Issue created, see it at #{task.url}"
      else
        Redpomo.ui.error "Cannot create issue, unknown tracker."
        exit 1
      end
    end

    desc "pull", "imports Redmine open issues into local todo.txt"
    def pull
      TaskList.pull_from_trackers!
    end

    desc "push [LOGFILE]", "parses Pomodoro export file and imports to Redmine clients"
    method_option :fuzzy,  aliases: "-f", type: :boolean
    method_option :dry_run, aliases: "-n", type: :boolean
    def push(path = nil)

      csv = if path.present?
              File.read(File.expand_path(path))
            else
              require 'applescript'
              AppleScript.execute('tell application "Pomodoro" to take log')
            end

      if csv.blank?
        if path.present?
          Redpomo.ui.error "Empty CSV provided!"
        else
          Redpomo.ui.error "Empty Pomodoro log!"
          Redpomo.ui.info "Maybe you need to this Pomodoro fork? https://github.com/stefanoverna/pomodoro"
        end
        exit 1
      end

      entries = Entry.load_from_csv(csv)
      entries = FuzzyConverter.convert(entries) if @options[:fuzzy]

      unpushable_entries = entries.select {|entry| !entry.pushable? }

      if unpushable_entries.any?
        Redpomo.ui.error "Some pomodoros cannot be associated with a proper issue/project."
        EntriesPrinter.print(unpushable_entries)
        exit 1
      end

      if @options[:dry_run]
        EntriesPrinter.print(entries)
      else
        entries.each(&:push!)
        Redpomo.ui.info "Pushed #{entries.count} time entries"
        if path.blank?
          AppleScript.execute('tell application "Pomodoro" to clear')
          Redpomo.ui.info "Cleared Pomodoro.app log"
        end
      end
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
      task.close_issue!(@options[:message])

      Redpomo.ui.info "Issue updated, see it at #{task.url}"
    end

    desc "init", "generates a .redpomo configuration file on your home directory"
    def init(path = '~/.redpomo')
      path =  File.expand_path(path)
      template "config.yml", path, verbose: false
      open_editor(path)
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

    def open_editor(path)
      editor = [ENV['REDPOMO_EDITOR'], ENV['VISUAL'], ENV['EDITOR']].find{|e| !e.nil? && !e.empty? }
      if editor
        command = "#{editor} #{path}"
        system(command)
        File.read(path)
      else
        Redpomo.ui.error("To open #{path}, set $EDITOR or $REDPOMO_EDITOR")
        exit 1
      end
    end

  end
end
