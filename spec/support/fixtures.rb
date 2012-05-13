module Spec
  module Fixtures

    def tmp(path)
      File.expand_path("../../tmp/#{path}", __FILE__)
    end

    def fixture(path)
      File.expand_path("../../fixtures/#{path}", __FILE__)
    end

    def read_fixture(path)
      File.read fixture(path)
    end

  end
end
