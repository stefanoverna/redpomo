require 'spec_helper'
require 'redpomo/entry'

describe Redpomo::Entry do

  describe "#csv_rows" do

    it "parses Pomodoro's classic invalid CSV format" do
      text = File.read(fixture("timelog.csv"))
      rows = Redpomo::Entry.csv_rows(text)
      expect(rows.size).to eq(2)
    end

    it "parses my Pomodoro fork proper CSV format" do
      text = File.read(fixture("proper_timelog.csv"))
      rows = Redpomo::Entry.csv_rows(text)
      expect(rows.size).to eq(4)
    end

  end

end

