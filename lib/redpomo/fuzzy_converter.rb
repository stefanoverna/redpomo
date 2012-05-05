require 'active_support/core_ext/numeric/time'
require 'redpomo/entry'

module Redpomo
  class FuzzyConverter

    def self.convert(entries)
      past_entry = nil
      consecutive_entries = []

      entries << nil

      result = []

      entries.each do |entry|
        if past_entry.present?
          if entry.present? && entry.same_date?(past_entry) && entry.same_text?(past_entry)
            consecutive_entries << entry
          else
            result << self.fuzzy_entry(consecutive_entries, entry)
            past_entry = entry
            consecutive_entries = [ entry ]
          end
        else
          past_entry = entry
          consecutive_entries = [ entry ]
        end
      end

      result
    end

    def self.fuzzy_entry(entries, next_entry)
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
      entry
    end

    # def strip!
    #   end_working_day = Time.new(time.year, time.month, time.day, 18, 30, 0, "+00:00")
    #   start_launch_time = Time.new(time.year, time.month, time.day, 13, 15, 0, "+00:00")
    #   end_launch_time = Time.new(time.year, time.month, time.day, 14, 15, 0, "+00:00")
    #   late_night_day = Time.new(time.year, time.month, time.day, 23, 59, 0, "+00:00")

    #   if time < end_working_day && end_time > end_working_day
    #     @duration = end_working_day - time
    #   elsif time < start_launch_time && end_time > end_launch_time
    #     @duration -= 3600.0
    #   elsif time < start_launch_time && end_time > start_launch_time
    #     @duration = start_launch_time - time
    #   elsif time > end_working_day && end_time > late_night_day
    #     @duration = late_night_day - time
    #   end
    # end

  end
end
