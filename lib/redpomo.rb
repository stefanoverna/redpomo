require 'active_support/core_ext/module/attribute_accessors'
require "redpomo/version"
require "redpomo/ui"

module Redpomo

  mattr_accessor :ui
  self.ui = UI.new

end
