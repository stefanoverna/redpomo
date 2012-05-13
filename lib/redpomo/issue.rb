module Redpomo
  class Issue

    attr_accessor :subject, :description
    attr_accessor :issue_id, :project_id, :tracker
    attr_accessor :due_date, :priority_id

    def initialize(tracker, data = {})
      @subject = data["subject"]
      @issue_id = data["id"]
      @project_id = data["project_id"]
      @priority_id = data["priority"]["id"] if data["priority"].present?
      @due_date = Date.parse(data["due_date"]) if data["due_date"].present?
      @tracker = tracker
    end

    def to_task
      label = []
      if @priority_id.present?
        if priority = @tracker.todo_priority(@priority_id)
          label << priority
        end
      end
      label << @due_date.strftime("%Y-%m-%d") if @due_date.present?
      label << @subject
      label << "##{issue_id}"
      label << "+#{project_id}"
      label << "@#{tracker.name}"
      Todo::Task.new(label.join(" "))
    end

    def create!
      data = tracker.create_issue!(self)
    end

  end
end
