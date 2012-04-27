module Todo
  class Task

    def include_contexts?(list)
      list.any? do |context|
        contexts.include? context
      end
    end

    def self.projects_regex
       /(?:\s+|^)\+[\w\-]+/
    end

    def self.issues_regex
       /(?:\s+|^)#\w+/
    end

    def issues
      @issues ||= orig.scan(self.class.issues_regex).map { |item| item.strip }
    end

    def text_with_issues_removed
      text_without_issues_removed.
        gsub(self.class.issues_regex, '').
        strip
    end
    alias_method_chain :text, :issues_removed

  end
end


