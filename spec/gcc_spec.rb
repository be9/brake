require File.dirname(__FILE__) + '/spec_helper'
require 'tmpdir'
require 'compilers/gcc'
require 'cache_mock'
require 'checks'

include Brake::Checks

describe "gcc" do
  include CacheMock

  before :all do
    @tmpdir = File.join(Dir.tmpdir, "brakegccspec#{$$}")
    Dir.mkdir @tmpdir
  end

  after :all do
    Dir.rmdir @tmpdir
  end

  before do
    @path = ENV['PATH']
    setup_cache
    @compiler = Brake::Compilers::Gcc.new("gcc")
  end

  after do
    ENV['PATH'] = @path
    Dir["#{@tmpdir}/*"].each { |f| File.unlink(f) }
    ['CC', 'CXX'].each { |e| ENV[e] = nil }
  end

  it "should respect :cc in options" do
    special_compiler = Brake::Compilers::Gcc.new("gcc", :cc => "/bin/false")

    special_compiler.probe

    special_compiler.conf[:cc].should == "/bin/false"
  end

  it "should try to use CC from environment" do
    ENV['CC'] = "/qq/qq"
    
    @compiler.probe

    @compiler.conf[:cc].should == "/qq/qq"
  end

  def try_name(name)
    ENV['PATH'] = @tmpdir
    gcc = @tmpdir + "/#{name}"
    File.symlink("/bin/false", gcc)

    @compiler.probe

    @compiler.conf[:cc].should == gcc
  end

  it "should try to find gcc command" do
    try_name('gcc')
  end
  
  it "should try to find cc command" do
    try_name('cc')
  end

  it "should find and probe real gcc" do
    @cache.should_receive(:save).once

    @compiler.probe

    @compiler.probed?.should == true
  end

  it "oneliner should be ok with weird names" do
    @cache.should_receive(:save).once
    @compiler.probe
    
    try_compile_and_run(" bad \"name'", "int main(){return 0;}\n", "c", @compiler).should_not == nil
  end
end
