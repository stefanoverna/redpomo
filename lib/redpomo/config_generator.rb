require 'thor/group'

module Redpomo
  class ConfigGenerator < Thor::Group
    include Thor::Actions
    argument :path, :type => :string

    def copy_config
      template("config.yml", File.expand_path(path))
    end

    def self.source_root
      File.dirname(__FILE__) + "/templates"
    end

  end
end
