require 'spec_helper'
require 'redpomo/task'

describe Redpomo::Task do

  describe ".orig" do
    it "returns the original line" do
      Redpomo::Task.new(stub, "Foo bar #123 +one @two").orig.should == "Foo bar #123 +one @two"
    end
  end

  describe ".url" do
    context "if there's an issue" do
      it "returns the URL to the issue" do
        tracker = stub(base_url: "http://foo.bar")
        task = Redpomo::Task.new(stub, "Foo #123 +project @tracker")
        task.stubs(:tracker).returns(tracker)
        task.url.should == "http://foo.bar/issues/123"
      end
    end
    context "if there's a project" do
      it "returns the URL to the project" do
        tracker = stub(base_url: "http://foo.bar")
        task = Redpomo::Task.new(stub, "Foo +project @tracker")
        task.stubs(:tracker).returns(tracker)
        task.url.should == "http://foo.bar/projects/project"
      end
    end
    context "else" do
      it "returns the URL to the tracker default project" do
        tracker = stub(base_url: "http://foo.bar", default_project: 'bar')
        task = Redpomo::Task.new(stub, "Foo @tracker")
        task.stubs(:tracker).returns(tracker)
        task.url.should == "http://foo.bar/projects/bar"
      end
    end
  end

end
