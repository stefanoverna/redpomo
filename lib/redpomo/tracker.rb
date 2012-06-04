require 'active_support/core_ext/hash'
require 'redpomo/issue'
require 'redpomo/config'

require 'rest_client'
require 'json'

module Redpomo
  class Tracker

    def self.find(name)
      if data = Config.trackers_data[name.to_sym]
        Tracker.new(name.to_sym, data)
      end
    end

    def self.all
      Config.trackers_data.map do |name, data|
        Tracker.new(name.to_sym, data)
      end
    end

    attr_reader :name, :base_url

    def initialize(name, options)
      options.symbolize_keys!
      @name = name
      @base_url = options[:url]
      @api_key = options[:token]
      @default_project_id = options[:default_project_id]
      @default_priority_id = options[:default_priority_id]
      @closed_status_id = options[:closed_status_id].to_i
      @default_activity_id = options[:default_activity_id]
      @priorities = options[:priority_ids]
    end

    def todo_priority(priority_name)
      return nil if @priorities.nil?
      alphabet = ('A' .. 'Z').to_a.join
      if index = @priorities.index(priority_name)
        "(#{alphabet[index]})"
      end
    end

    def issue_priority_id(priority_val)
      if index = ('A' .. 'Z').to_a.index(priority_val)
        @priorities[index]
      end
    end

    def issues
      data = get("/issues", assigned_to_id: current_user_id, status_id: "open", limit: 100)
      data["issues"].map do |issue|
        issue["project_id"] = project_identifier_for(issue["project"]["id"])
        Issue.new(self, issue)
      end
    end

    def create_issue!(issue)
      data = {
        subject: issue.subject,
        description: issue.description,
        due_date: issue.due_date,
        project_id: issue.project_id || @default_project_id,
        priority_id: issue.priority_id || @default_priority_id,
        assigned_to_id: current_user_id
      }

      post("/issues", issue: data)
    end

    def push_entry!(entry)
      task = entry.to_task
      time_entry = {}

      if issue = task.issue
        time_entry[:issue_id] = issue
      elsif project = task.project
        time_entry[:project_id] = project
      else
        time_entry[:project_id] = @default_project_id
      end

      time_entry[:spent_on] = entry.datetime
      time_entry[:hours] = entry.duration / 3600.0
      time_entry[:comments] = task.text

      if @default_activity_id.present?
        time_entry[:activity_id] = @default_activity_id.to_i
      end

      post("/time_entries", time_entry: time_entry)
    end

    def close_issue!(id, message = nil)
      issue = { status_id: @closed_status_id }
      issue[:notes] = message if message.present?
      put("/issues/#{id}", issue: issue)
    end

    private

    def project_identifier_for(project_id)
      Config.cache.get("#{@name}:#{project_id}:identifier") do
        data = get("/projects/#{project_id}")
        data["project"]["identifier"]
      end
    end

    def current_user_id
      get("/users/current")["user"]["id"]
    end

    def get(url, params = {})
      request(:get, url, params)
    end

    def post(url, data)
      request(:post, url, body: data)
    end

    def put(url, data)
      request(:put, url, body: data)
    end

    def request(type, url, params = {})
      args = []
      args << @base_url + url + ".json"
      args << params.delete(:body).to_json unless type == :get
      args << {
        accept: :json,
        content_type: :json,
        params: params.merge(key: @api_key)
      }
      parse RestClient.send(type, *args)
    end

    def parse(json)
      json && json.length >= 2 ? JSON.parse(json) : nil
    end

  end
end
