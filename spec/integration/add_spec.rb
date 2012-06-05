require 'tempfile'
require 'spec_helper'

describe "redpomo add" do

  let(:config_path) { tmp_path('redpomo') }

  it "opens up a template file with REDPOMO_EDITOR as highest priority" do
    redpomo "add", :env => {"EDITOR" => "echo editor", "VISUAL" => "echo visual", "REDPOMO_EDITOR" => "echo redpomo_editor"}
    out.should =~ /^redpomo_editor .*issue.*\.textile/
  end

  it "opens up a template file with VISUAL as 2nd highest priority" do
    redpomo "add", :env => {"EDITOR" => "echo editor", "VISUAL" => "echo visual", "REDPOMO_EDITOR" => ""}
    out.should =~ /^visual .*issue.*\.textile/
  end

  it "opens up a template file with EDITOR as 3rd highest priority" do
    redpomo "add", :env => {"EDITOR" => "echo editor", "VISUAL" => "", "REDPOMO_EDITOR" => ""}
    out.should =~ /^editor .*issue.*\.textile/
  end

  it "complains if no EDITOR is set" do
    redpomo "add", :env => {"EDITOR" => "", "VISUAL" => "", "REDPOMO_EDITOR" => ""}
    out.should include "set $EDITOR or $REDPOMO_EDITOR"
  end

end

