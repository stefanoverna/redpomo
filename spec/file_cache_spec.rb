require 'spec_helper'
require 'redpomo/file_cache'
require 'tempfile'

describe Redpomo::FileCache do

  describe "#get" do
    it "executes the block on cache miss" do
      Redpomo::FileCache.instance.cache_path = Tempfile.new('cache').path
      counter = Redpomo::FileCache.get("foobar") { 5 }
      counter.should == 5
      counter = Redpomo::FileCache.get("foobar") { 10 }
      counter.should == 5
    end
  end

end
