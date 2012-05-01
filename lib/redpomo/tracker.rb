require 'redpomo/issue'
require 'redpomo/cache'

module Redpomo

  class Tracker
    attr_reader :name

    def initialize(options)
      options.symbolize_keys!
      @name = options[:name]
      @base_url = options[:url]
      @api_key = options[:token]
      @default_project = options[:default_project]
      @closed_status_id = options[:closed_status]
    end

    def context
      "@#{name}"
    end

    def current_user_id
      get("/users/current")["user"]["id"]
    end

    def issues
      data = get("/issues", assigned_to_id: current_user_id, status_id: "open")
      data["issues"].map do |issue|
        issue["project"] = project_identifier_for(issue["project"]["id"])
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

      post("/time_entries", time_entry: time_entry)
    end

    def close_issue(id, message = nil)
      put("/issues/#{id}", issue: { status_id: "5", notes: message })
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

    private

    def project_identifier_for(project_id)
      Cache.get("#{@name}:#{project_id}:identifier") do
        data = get("/projects/#{project_id}")
        data["project"]["identifier"]
      end
    end

    def get(url, params = {})
      params = params.merge(key: @api_key)
      result = RestClient.get(@base_url + url + ".json", params: params, accept: :json, content_type: :json)
      JSON.parse(result)
    end

    def put(url, data)
      result = RestClient.put(@base_url + url + ".json", data.to_json, params: { key: @api_key }, accept: :json, content_type: :json)
      JSON.parse(result)
    end

    def post(url, data)
      result = RestClient.post(@base_url + url + ".json", data.to_json, params: { key: @api_key }, accept: :json, content_type: :json)
      JSON.parse(result)
    end

  end
end
