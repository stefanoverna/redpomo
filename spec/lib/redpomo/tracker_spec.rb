require 'spec_helper'
require 'redpomo/tracker'

describe Redpomo::Tracker do

  subject do
    Redpomo::Tracker.new(
      "welaika",
      url: "http://code.welaika.com",
      token: "WELAIKA_TOKEN",
      closed_status: "5"
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
        issues.first.project.should == 'dashboard-fiat'
        issues.first.issue_id.should == 3316
        issues.first.due_date.should be_nil
      end
    end
  end

end
