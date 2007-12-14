require File.dirname(__FILE__) + '/spec_helper'
require 'compilers'
require 'cache_mock'

describe "compiler" do
  include CacheMock

  before do
    setup_cache
    @compiler = Brake::Compilers::Compiler.new(:supercompilah, {})
  end

  it "should be not probed at first" do
    @compiler.probed?.should == false 
  end

  def detector(result)
    @compiler.stub!(:detect).and_return(result)
    
    @cache.should_receive(:save).once if result

    @compiler.probe
    @compiler.probed?.should == result
    
    @cache_hash['compilers']['supercompilah'][:probed].should == true if result
  end

  it "should be in a probed state after detection" do
    detector(true)
  end

  it "should not be in probed state if detection failed" do
    detector(false)
  end

  it "should not probe twice" do
    detector(true)
    
    @compiler.stub!(:detect).and_raise()

    # would raise upon second call of detect
    @compiler.probe
  end

  it "should not support any extensions" do
    @compiler.known_extensions.should == []
    detector(true)
    @compiler.known_extensions.should == []
  end
end
