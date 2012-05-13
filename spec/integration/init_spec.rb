require 'tempfile'
require 'spec_helper'

describe "redpomo init" do

  let(:config_path) {
    new_config = Tempfile.new('redpomo')
    new_config_path = new_config.path
    new_config.unlink
    new_config_path
  }

  it "generates a .redpomo config file" do
    redpomo "init #{config_path}", env: { "EDITOR" => "echo editor" }
    File.exists?(config_path).should be_true
  end

  it "opens the config with REDPOMO_EDITOR as highest priority" do
    redpomo "init #{config_path}", :env => {"EDITOR" => "echo editor", "VISUAL" => "echo visual", "REDPOMO_EDITOR" => "echo redpomo_editor"}
    out.should == "redpomo_editor #{config_path}"
  end

  it "opens the config with VISUAL as 2nd highest priority" do
    redpomo "init #{config_path}", :env => {"EDITOR" => "echo editor", "VISUAL" => "echo visual", "REDPOMO_EDITOR" => ""}
    out.should == "visual #{config_path}"
  end

  it "opens the config with EDITOR as 3rd highest priority" do
    redpomo "init #{config_path}", :env => {"EDITOR" => "echo editor", "VISUAL" => "", "REDPOMO_EDITOR" => ""}
    out.should == "editor #{config_path}"
  end

  it "complains if no EDITOR is set" do
    redpomo "init #{config_path}", :env => {"EDITOR" => "", "VISUAL" => "", "REDPOMO_EDITOR" => ""}
    out.should == "To open the .redpomo config file, set $EDITOR or $REDPOMO_EDITOR"
  end

end