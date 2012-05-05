require 'terminal-table'

require 'redpomo/entry'
require 'redpomo/config'

module Redpomo
  class Pusher

    def initialize(log_path, options = {})
      @options = options
      @log_path = File.expand_path(log_path)
    end

    def execute
      entries_to_push = @options[:fuzzy] ? fuzzy_entries : entries

      unless @options[:dry_run]
        entries_to_push.each do |entry|
          tracker = config.tracker_for_task(entry.to_task)
          tracker.push_entry(entry)
        end
      end

      entries_to_push.group_by(&:date).each do |date, entries|
        duration = 0
        rows = entries.map do |entry|
          task = entry.to_task
          duration += entry.duration
          [ task.contexts.first, task.projects.first, task.issues.first, task.text, entry.duration.seconds_in_words, I18n.l(entry.time, format: "%H:%M"), I18n.l(entry.end_time, :format => "%H:%M") ]
        end
        puts Terminal::Table.new(
          title: "#{ I18n.l(date, format: "%A %x") } - #{ duration.seconds_in_words }",
          headings: [ "Context", "Project", "Issue #", "Description", "Duration", "From", "To" ],
          rows: rows
        )
        puts
      end

    end

    private

    def config
      @config ||= Redpomo::Config.new(@options[:config])
    end

    def entries
      @entries ||= raw_log.map do |line_data|
        Entry.from_csv(line_data)
      end.sort_by { |entry| entry.datetime }
    end

    def raw_log
      CSV.parse File.read(@log_path).split("\n")[4..-1].join("\n")
    end


  end
end
