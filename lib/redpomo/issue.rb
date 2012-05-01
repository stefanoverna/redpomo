module Redpomo
  class Issue

    attr_reader :title, :issue_id, :project, :tracker

    def initialize(tracker, data)
      @title = data["subject"]
      @issue_id = data["id"]
      @project = data["project"]
      @due_date = Date.parse(data["due_date"]) if data["due_date"].present?
      @tracker = tracker
    end

    def to_task
      label = [ title ]
      label << @due_date.strftime("%Y-%m-%d") if @due_date.present?
      label << "##{issue_id}"
      label << "+#{project}"
      label << "@#{tracker}"
      Todo::Task.new(label.join(" "))
    end

  end
end
