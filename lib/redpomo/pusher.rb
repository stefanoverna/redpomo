require 'redpomo/entry'
require 'redpomo/config'

module Redpomo
  class Pusher

    def initialize(log_path, options = {})
      @options = options
      @log_path = File.expand_path(log_path)
    end

    def execute
      (@options[:fuzzy] ? fuzzy_entries : entries).each do |entry|
        tracker = config.tracker_for_task(entry.to_task)
        tracker.push_entry(entry)
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

    def fuzzy_entries
      past_entry = nil
      similar_entries = []

      entries << nil

      result = []

      entries.each do |entry|
        if past_entry.present?
          if entry.present? && entry.same_date?(past_entry) && entry.same_text?(past_entry)
            similar_entries << entry
          else
            result << fuzzy_entry(similar_entries, entry)
            past_entry = entry
            similar_entries = [ entry ]
          end
        else
          past_entry = entry
          similar_entries = [ entry ]
        end
      end
      result
    end

    def fuzzy_entry(entries, next_entry)
      first_entry = entries.first
      last_entry = entries.last
      total_duration = first_entry.time - last_entry.end_time
      duration_till_next_entry = next_entry.time - last_entry.end_time if next_entry.present?

      entry = if next_entry.nil? || duration_till_next_entry > 1.5 * 3600.0
        duration = last_entry.end_time - first_entry.time
        duration += 1.5 * 3600.0 if next_entry.present? && next_entry.same_date?(last_entry)
        Entry.new(first_entry.text, first_entry.datetime, duration)
      else
        duration = next_entry.time - first_entry.time
        entry = Entry.new(first_entry.text, first_entry.datetime, duration)
      end
      entry.strip!
      entry
    end

  end
end
