module Redpomo
  class Issue

    attr_reader :title, :issue_id, :project, :tracker

    def initialize(tracker, data)
      @title = data["subject"]
      @issue_id = data["id"]
      @project = data["project"]
      @tracker = tracker
    end

    def to_task
      Todo::Task.new("#{title} ##{issue_id} +#{project} @#{tracker}")
    end

  end
end
