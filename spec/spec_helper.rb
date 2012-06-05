require 'rubygems'
require 'bundler'
require 'active_support/core_ext/object'

if ENV['SIMPLECOV']
  require 'simplecov'
  SimpleCov.start
end

Bundler.require(:default, :development)

require 'support/ruby_ext'
require 'support/cli_helpers'
require 'support/fixtures'

RSpec.configure do |config|
  config.mock_framework = :mocha
  config.include Spec::CLIHelpers
  config.include Spec::Fixtures
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.hook_into :webmock
  c.default_cassette_options = {
    match_requests_on: [:method, :host, :path, :body]
  }
end
