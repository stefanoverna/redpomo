require 'spec_helper'
require 'launchy'
require 'applescript'
require 'redpomo/cli'
require 'fileutils'

describe Redpomo::CLI do

  let(:todo_path) {
    file = File.open(tmp('tasks.txt'), 'w')
    file.write read_fixture("tasks.txt")
    file.close
    file.path
  }

  let(:config_path) {
    config = YAML::load_file fixture("config.yml")
    config["todo"] = todo_path
    file = File.open(tmp('config.yml'), 'w')
    file.write config.to_yaml
    file.close
    file.path
  }

  describe "push LOG" do
    it "pushes the specified timelog to remote trackers" do
      VCR.use_cassette('cli_push') do
        cli_redpomo "push #{fixture("timelog.csv")}"
        out.strip.should == "Pushed 2 time entries!"
      end
    end
  end

  describe "push -n LOG" do
    it "pushes the specified timelog to remote trackers" do
      VCR.use_cassette('cli_push') do
        cli_redpomo "push -n #{fixture("timelog.csv")}"
        out.should == read_fixture("printer_output.txt")
      end
    end
  end

  describe "start ISSUE" do
    it "starts the specified issue on Pomodoro.app" do
      AppleScript.expects(:execute).with('tell application "Pomodoro" to start "Make screenshot #838 @cantiere"')
      cli_redpomo "start 1"
    end
  end

  describe "open ISSUE" do
    it "shows the specified issue on the browser" do
      Launchy.expects(:open).with('https://project.cantierecreativo.net/issues/838')
      cli_redpomo "open 1"
    end
  end

  describe "close ISSUE" do
    it "closes issue on remote tracker and marks current task as done" do
      VCR.use_cassette('cli_close') do
        cli_redpomo "close 2 -m bar"
        File.read(todo_path).should == read_fixture("close_results.txt")
        out.strip.should == 'Issue updated, see it at http://code.welaika.com/issues/3290'
      end
    end
  end

  describe "pull" do
    it "fetches all the trackers and converts the issues in todo tasks" do
      VCR.use_cassette('cli_pull') do
        cli_redpomo "pull"
        File.read(todo_path).should == read_fixture("pull_results.txt")
      end
    end
  end

  describe "add" do
    it "creates a new task, adds it the list, and pushes it to the tracker" do
      VCR.use_cassette('cli_add') do
        cli_redpomo ["add", "foobar +olasagasti @welaika"]
        File.read(todo_path).should == read_fixture("add_results.txt")
        out.strip.should == 'Issue created, see it at http://code.welaika.com/issues/3397'
      end
    end
  end

  after(:each) do
    File.unlink(todo_path)
    File.unlink(config_path)
  end

end
