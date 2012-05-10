require 'spec_helper'
require 'tempfile'
require 'launchy'
require 'applescript'
require 'redpomo/cli'

describe Redpomo::CLI do

  let(:todo_tasks) do
    [
      "Make screenshot #838 @cantiere",
      "Fix #3290 @welaika",
      "Another task @home"
    ]
  end

  let(:todo_file) do
    Tempfile.new('todo')
  end

  let(:config) do
    {
      "todo" => todo_file.path,
      "cache" => false,
      "trackers" => {
        "cantiere" => {
          "url" => "https://project.cantierecreativo.net",
          "token" => "CANTIERE_TOKEN",
          "default_project" => "cc",
          "closed_status" => 5
        },
        "welaika" => {
          "url" => "http://code.welaika.com",
          "token" => "WELAIKA_TOKEN",
          "default_project" => "welaika",
          "closed_status" => 5
        }
      }
    }
  end

  let(:config_file) do
    Tempfile.new('config')
  end

  before(:each) do
    todo_file.write(todo_tasks.join("\n"))
    todo_file.close
    config_file.write(config.to_yaml)
    config_file.close
  end

  after(:each) do
    todo_file.unlink
    config_file.unlink
  end

  describe "push LOG" do
    it "pushes the specified timelog to remote trackers" do
      VCR.use_cassette('cli_push') do
        output = capture(:stdout) do
          Redpomo::CLI.start("push spec/fixtures/timelog.csv --config #{config_file.path}".split)
        end
        output.should == File.read("spec/fixtures/printer_output.txt")
      end
    end
  end

  describe "start ISSUE" do
    it "starts the specified issue on Pomodoro.app" do
      AppleScript.expects(:execute).with('tell application "Pomodoro" to start "Make screenshot #838 @cantiere"')
      Redpomo::CLI.start("start 1 --config #{config_file.path}".split)
    end
  end

  describe "open ISSUE" do
    it "shows the specified issue on the browser" do
      Launchy.expects(:open).with('https://project.cantierecreativo.net/issues/838')
      Redpomo::CLI.start("open 1 --config #{config_file.path}".split)
    end
  end

  describe "close ISSUE" do
    it "closes issue on remote tracker and marks current task as done" do
      VCR.use_cassette('cli_close') do
        Redpomo::CLI.start("close 1 --config #{config_file.path}".split)
        File.read(todo_file.path).should == File.read("spec/fixtures/close_results.txt")
      end
    end
  end

  describe "pull" do
    it "fetches all the trackers and converts the issues in todo tasks" do
      VCR.use_cassette('cli_pull') do
        Redpomo::CLI.start("pull --config #{config_file.path}".split)
        File.read(todo_file.path).should == File.read("spec/fixtures/pull_results.txt")
      end
    end
  end

  pending "init"

end
