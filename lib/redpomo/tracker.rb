require 'redpomo/issue'

module Redpomo

  class Tracker
    attr_reader :name

    def initialize(name, url, api_key, default_project)
      @name = name
      @base_url = url
      @api_key = api_key
      @default_project = default_project
    end

    def context
      "@#{name}"
    end

    def current_user_id
      data = RestClient.get(
        "#{@base_url}/users/current.json",
        params: { key: @api_key },
        accept: :json,
        content_type: :json
      )
      JSON.parse(data)["user"]["id"]
    end

    def issues
      data = RestClient.get(
        "#{@base_url}/issues.json",
        params: {
          key: @api_key,
          assigned_to_id: current_user_id,
          status_id: "open"
        },
        accept: :json,
        content_type: :json
      )

      projects = JSON.parse(data)["issues"].map do |issue|
        issue["project"]["id"]
      end.uniq.inject ({}) do |result, id|
        d = RestClient.get(
          "#{@base_url}/projects/#{id}.json",
          params: { key: @api_key },
          accept: :json,
          content_type: :json
        )
        result[id] = JSON.parse(d)["project"]["identifier"]
        result
      end

      JSON.parse(data)["issues"].map do |issue|
        issue["project"] = projects[issue["project"]["id"]]
        Issue.new(@name, issue)
      end
    end

    def push_entry(entry)
      task = entry.to_task
      time_entry = {}

      if task.issues.any?
        time_entry[:issue_id] = task.issues.first.gsub(/^#/,'')
      elsif task.projects.any?
        time_entry[:project_id] = task.projects.first.gsub(/^\+/,'')
      else
        time_entry[:project_id] = @default_project
      end

      time_entry[:spent_on] = entry.datetime
      time_entry[:hours] = entry.duration / 3600.0
      time_entry[:comments] = task.text

      RestClient.post(
        "#{@base_url}/time_entries.json",
        { time_entry: time_entry }.to_json,
        params: { key: @api_key },
        accept: :json,
        content_type: :json
      )

    end

    def url_for(object)
      if object.is_a? Todo::Task
        if object.issues.any?
          issue = object.issues.first.gsub(/^#/,'')
          "#{@base_url}/issues/#{issue}"
        elsif object.projects.any?
          project = task.projects.first.gsub(/^\+/,'')
          "#{@base_url}/projects/#{issue}"
        else
          "#{@base_url}/projects/#{@default_project}"
        end
      end
    end

  end
end
