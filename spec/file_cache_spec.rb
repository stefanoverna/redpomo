require 'spec_helper'
require 'redpomo/file_cache'
require 'tempfile'

describe Redpomo::FileCache do

  describe "#get" do
    it "executes the block on cache miss" do
      old_cache_path = Redpomo::FileCache.instance.cache_path
      Redpomo::FileCache.instance.cache_path = tmp_path("cache_file")

      counter = Redpomo::FileCache.get("foobar") { 5 }
      counter.should == 5

      counter = Redpomo::FileCache.get("foobar") { 10 }
      counter.should == 5

      Redpomo::FileCache.instance.cache_path = old_cache_path
    end
  end

end
