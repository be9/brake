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

    # we don't mind whether save is called or not
    @cache.stub!(:save).and_return()

    @compiler    = Brake::Compilers::Gcc.new("gcc")
    @cxxcompiler = Brake::Compilers::Gcc.new("gcc", :detect_cxx => true)
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
  
  it "should respect :cxx in options" do
    special_compiler = Brake::Compilers::Gcc.new("gcc", :cxx => "/bin/false", :detect_cxx => true)

    special_compiler.probe

    special_compiler.conf[:cxx].should == "/bin/false"
  end

  it "should try to use CC from environment" do
    ENV['CC'] = "/qq/qq"
    
    @compiler.probe

    @compiler.conf[:cc].should == "/qq/qq"
  end
  
  it "should try to use CXX from environment" do
    ENV['CXX'] = "/qq/qq"
    
    @cxxcompiler.probe

    @cxxcompiler.conf[:cxx].should == "/qq/qq"
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
    
    try_compile_and_run(" bad \"name'", "int main(){return 0;}\n", "c", @compiler).should == ""
  end

  it "should compile only one program in when in C mode" do 
    pending("WTF")
    mcount = mock('Counter')

    class << @compiler
      def set_mock(mock)
        @trymock = mock
      end

      def try_compile_and_run(*args)
        @trymock.send(:try_compile_and_run, *args)
      end
    end

    @compiler.set_mock(mcount)
    @compiler.probe
  end

  it "should not support .c extension when not probed" do
    @compiler.known_extensions.include?("c").should == false
  end
  
  it "should support .c extension when probed" do
    @compiler.probe
    @compiler.known_extensions.include?("c").should == true
  end
  
  def try_name_cxx(name)
    ENV['PATH'] = @tmpdir

    # this will be used for a C compiler, which is probed first
    File.symlink("/usr/bin/gcc", @tmpdir + "/gcc")

    gxx = @tmpdir + "/#{name}"
    File.symlink("/bin/true", gxx)
    
    @cxxcompiler.probe
    
    @cxxcompiler.conf[:cxx].should == gxx
  end
  
  it "should try to find g++ command" do
    try_name_cxx('g++')
  end
  
  it "should try to find c++ command" do
    try_name_cxx('c++')
  end

  it "should not detect CXX compiler unless asked to" do
    @compiler.probe
    @compiler.conf[:cxx_probed].should_not == true
  end
  
  it "should probe CXX compiler when asked" do
    @cxxcompiler.probe
    @cxxcompiler.conf[:cxx_probed].should == true
  end

  it "should run C compiler for files with .c extension" do
    @compiler.compiler_for_source_file("test.c").should == :cc
  end
  
  it "should run C++ compiler for files with C++ extensions" do
    ["cxx","cpp","c++","cc","C"].each do |ext|
      @compiler.compiler_for_source_file("test.#{ext}").should == :cxx
    end
  end

  it "should not compile an invalid program" do
    @compiler.probe
    try_compile_and_run('testgcc', 'an invalid C code', 'c', @compiler).should.nil?
  end

end
