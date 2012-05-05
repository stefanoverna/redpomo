require 'redpomo/numeric_ext'

module Redpomo
  class EntriesPrinter

    def self.print(entries)
      require 'terminal-table'
      entries.group_by(&:date).each do |date, entries|
        duration = 0
        rows = entries.map do |entry|
          task = entry.to_task
          duration += entry.duration
          [
            task.context,
            task.project,
            task.issue,
            task.text,
            entry.duration.seconds_in_words,
            I18n.l(entry.time, format: "%H:%M"),
            I18n.l(entry.end_time, :format => "%H:%M")
          ]
        end
        puts Terminal::Table.new(
          title: "#{ I18n.l(date, format: "%A %x") } - #{ duration.seconds_in_words }",
          headings: [ "Context", "Project", "Issue #", "Description", "Duration", "From", "To" ],
          rows: rows
        )
        puts
      end
    end

  end
end
