module Redpomo
  class Entry
    attr_reader :text, :datetime, :duration

    def self.from_csv(data)
      entry = Entry.new(data[0], DateTime.parse(data[1]), data[2].to_i * 60.0)
    end

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
      Todo::Task.new(text)
    end

    def strip!
      end_working_day = Time.new(time.year, time.month, time.day, 18, 30, 0, "+00:00")
      start_launch_time = Time.new(time.year, time.month, time.day, 13, 15, 0, "+00:00")
      end_launch_time = Time.new(time.year, time.month, time.day, 14, 15, 0, "+00:00")
      late_night_day = Time.new(time.year, time.month, time.day, 23, 59, 0, "+00:00")

      if time < end_working_day && end_time > end_working_day
        @duration = end_working_day - time
      elsif time < start_launch_time && end_time > end_launch_time
        @duration -= 3600.0
      elsif time < start_launch_time && end_time > start_launch_time
        @duration = start_launch_time - time
      elsif time > end_working_day && end_time > late_night_day
        @duration = late_night_day - time
      end

    end

  end
end
