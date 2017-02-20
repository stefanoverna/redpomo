# -*- encoding: utf-8 -*-
require File.expand_path('../lib/redpomo/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Stefano Verna"]
  gem.email         = ["stefano.verna@welaika.com"]
  gem.description   = %q{A nice little gem that integrates Redmine, Todo.txt and Pomodoro.app}
  gem.summary       = %q{A nice little gem that integrates Redmine, Todo.txt and Pomodoro.app}
  gem.homepage      = ""

  gem.files         = Dir.glob("./**/*")
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "redpomo"
  gem.require_paths = ["lib"]
  gem.version       = Redpomo::VERSION

  gem.add_dependency "activesupport"
  gem.add_dependency "thor"
  gem.add_dependency "todo-txt"
  gem.add_dependency "rest-client"
  gem.add_dependency "launchy"
  gem.add_dependency "applescript"
  gem.add_dependency "terminal-table"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "guard-rspec"
  gem.add_development_dependency "vcr"
  gem.add_development_dependency "webmock"
  gem.add_development_dependency "mocha"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "rake"
end
