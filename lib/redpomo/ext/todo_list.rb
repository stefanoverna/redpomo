module Todo
  class List
    def write_to(path)
      File.open(path, 'w') do |file|
        file.write map(&:orig).join("\n")
      end
    end
  end
end

