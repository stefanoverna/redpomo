require 'spec_helper'
require 'redpomo/tracker'

describe Redpomo::Tracker do

  subject do
    Redpomo::Tracker.new(
      "welaika",
      url: "http://code.welaika.com",
      token: "1dd4ac72b085df0e91c84b924c36cad48e7b5481",#"WELAIKA_TOKEN",
      closed_status_id: "5"
    )
  end

  describe ".close_issue!" do
    it "closes the issue with the specified message" do
      VCR.use_cassette('close_issue') do
        lambda {
          subject.close_issue!("3290", "foobar")
        }.should_not raise_error
      end
    end
  end

  describe ".issues" do
    it "creates an Issue for each remote issue" do
      VCR.use_cassette('issues') do
        issues = subject.issues
        issues.should have(7).issues
        issues.first.tracker.should == subject
        issues.first.project_id.should == 'dashboard-fiat'
        issues.first.issue_id.should == 3316
        issues.first.due_date.should be_nil
      end
    end
  end

  describe ".push_entry!" do
    it "creates a TimeEntry" do
      VCR.use_cassette('push_entry') do
        task = stub(
          issue: 3392,
          text: "Foobar"
        )
        entry = stub(
          to_task: task,
          datetime: Date.new(2012, 1, 1),
          duration: 5
        )
        result = subject.push_entry!(entry)
        result["time_entry"]["issue"]["id"].should == 3392
      end
    end
  end

  describe ".create_issue!" do
    it "creates an Issue" do
      VCR.use_cassette('create_issue') do
        issue = stub(
          subject: "foo",
          description: "bar",
          due_date: Date.new(2012, 12, 1),
          project_id: "olasagasti",
          priority_id: 5
        )
        result = subject.create_issue!(issue)
        result["issue"]["id"].should be_present
      end
    end
  end

end
