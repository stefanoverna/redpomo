require 'spec_helper'

describe Redpomo::Entry do

  describe "#csv_rows" do

    it "parses Pomodoro's classic invalid CSV format" do
      text = File.read(fixture("timelog.csv"))
      rows = Redpomo::Entry.csv_rows(text)
      rows.should have(2).rows
    end

    it "parses my Pomodoro fork proper CSV format" do
      text = File.read(fixture("proper_timelog.csv"))
      rows = Redpomo::Entry.csv_rows(text)
      rows.should have(4).rows
    end

  end

end

