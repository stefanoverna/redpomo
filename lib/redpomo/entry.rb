require 'csv'

module Redpomo
  class Entry

    def self.load_from_csv(text)
      csv_rows(text).map do |data|
        Entry.new(data[0], DateTime.parse(data[1]), data[2].to_i * 60.0) if data.size >= 3
      end.compact.sort_by { |entry| entry.datetime }
    end

    def self.csv_rows(text)
      if text.match /^Export data created/
        CSV.parse text.split("\n")[4..-1].join("\n")
      else
        CSV.parse text
      end
    end

    attr_reader :text, :datetime, :duration

    def initialize(text, datetime, duration)
      @text = text
      @datetime = datetime
      @duration = duration
    end

    def date
      datetime.to_date
    end

    def time
      datetime.to_time
    end

    def end_time
      time + duration
    end

    def same_date?(entry)
      date == entry.date
    end

    def same_text?(entry)
      text == entry.text
    end

    def to_task
      Task.new(nil, text)
    end

    def push!
      tracker.push_entry!(self) if pushable?
    end

    def pushable?
      tracker.present? && tracker.pushable_entry?(self)
    end

    def tracker
      to_task.tracker
    end

  end
end
