module Redpomo
  class NullCache

    def self.get(key, &block)
      block.call
    end

  end
end
