require 'csv'

module Redpomo
  class Entry

    def self.load_from_csv(path)
      CSV.parse(File.read(path).split("\n")[4..-1].join("\n")).map do |data|
        Entry.new(data[0], DateTime.parse(data[1]), data[2].to_i * 60.0)
      end.sort_by { |entry| entry.datetime }
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
      to_task.tracker.push_entry!(self)
    end

  end
end
