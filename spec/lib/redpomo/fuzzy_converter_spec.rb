require 'spec_helper'
require 'redpomo/fuzzy_converter'

describe Redpomo::FuzzyConverter do

  let(:converted_entries) do
    Redpomo::FuzzyConverter.convert(entries)
  end

  describe "#convert" do

    context "if there's up to 1.5h of untracked time between entries" do
      let(:entries) do
        [
          Redpomo::Entry.new("foo", DateTime.parse('5th feb 2012 09:00:00'), 25.minutes),
          Redpomo::Entry.new("bar", DateTime.parse('5th feb 2012 10:00:00'), 25.minutes),
        ]
      end
      it "fills up time between entries" do
        converted_entries.first.duration.should == 1.hour
      end
    end

    context "if there's more than 1.5h of untracked time between entries" do
      let(:entries) do
        [
          Redpomo::Entry.new("foo", DateTime.parse('5th feb 2012 09:00:00'), 25.minutes),
          Redpomo::Entry.new("bar", DateTime.parse('5th feb 2012 12:00:00'), 25.minutes),
        ]
      end
      it "it adds 1.5 hours between entries" do
        converted_entries.first.duration.should == (25.minutes + 1.5.hour)
      end
    end

    context "on multiple consecutive entries with the same task" do
      context "in the same day" do
        let(:entries) do
          [
            Redpomo::Entry.new("foo", DateTime.parse('5th feb 2012 09:00:00'), 25.minutes),
            Redpomo::Entry.new("foo", DateTime.parse('5th feb 2012 09:30:00'), 25.minutes),
            Redpomo::Entry.new("bar", DateTime.parse('5th feb 2012 12:00:00'), 25.minutes),
          ]
        end
        it "it joins them" do
          converted_entries.first.duration.should == (30.minutes + 25.minutes + 1.5.hour)
        end
      end
      context "on different days" do
        let(:entries) do
          [
            Redpomo::Entry.new("foo", DateTime.parse('5th feb 2012 09:00:00'), 25.minutes),
            Redpomo::Entry.new("foo", DateTime.parse('6th feb 2012 09:30:00'), 25.minutes),
          ]
        end
        it "it keeps them separated" do
          converted_entries.should have(2).entries
          converted_entries.first.duration.should == 25.minutes
          converted_entries.last.duration.should == 25.minutes
        end
      end
    end

  end
end
