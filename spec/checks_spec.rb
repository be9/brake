require File.dirname(__FILE__) + '/spec_helper'
require 'checks'
require 'tmpdir'

include Brake::Checks

describe "find_program" do
  before :all do
    @tmpdir = File.join(Dir.tmpdir, "brakemakespec#{$$}")
    Dir.mkdir @tmpdir

    @fakeruby = File.join(@tmpdir, "ruby")
    File.open(@fakeruby, "w") do |f|
      f.puts "#!/bin/sh"
    end

    File.chmod 0755, @fakeruby
    
    @justafile = File.join(@tmpdir, "justafile")
    File.open(@justafile, "w") do |f|
      f.puts "justafile"
    end
  end

  after :all do
    File.unlink @fakeruby
    File.unlink @justafile
    Dir.rmdir @tmpdir
  end

  it "should find nothing if path is unset" do 
    savepath = ENV['PATH']

    ENV['PATH'] = ''

    find_program("ruby").should.nil?

    ENV['PATH'] = savepath
  end
  
  it "should find ruby interpreter" do
    find_program("ruby").should == "/usr/bin/ruby"
  end

  it "should find ruby interpreter given by absolute path" do
    find_program("/usr/bin/ruby").should == "/usr/bin/ruby"
  end
  
  it "should not find non-executable files given by absolute path" do
    find_program("/etc/passwd").should.nil?
  end

  it "should respect paths argument" do 
    find_program("ruby", [@tmpdir]).should == @fakeruby
  end
  
  it "should not find non-executable files" do 
    find_program("justafile", [@tmpdir]).should.nil?
  end
end

describe "try_compile_and_run" do
  before :all do
    @saveddir = Dir.pwd
    Dir.chdir File.dirname(__FILE__)
  end

  after :all do
    Dir.chdir @saveddir
  end

  before do
    @compiler = mock('compiler')
  end
  
  it "should set proper extension for source" do 
    @compiler.should_receive(:oneliner).with(/\.c$/, an_instance_of(String)).once.and_return(true)
    
    try_compile_and_run('name', '', 'c', @compiler)
    
    compiler2 = mock('compiler')
    compiler2.should_receive(:oneliner).with(/\.qqq$/, an_instance_of(String)).once.and_return(true)
    
    try_compile_and_run('name', '', 'qqq', compiler2)
  end

  it "should call oneliner with both source and target in tmp dir" do
    @compiler.should_receive(:oneliner) do |source, target|
      tmp = File.expand_path('./tmp')
      File.expand_path(File.dirname(source)).should == tmp
      File.expand_path(File.dirname(target)).should == tmp

      true
    end 
    
    try_compile_and_run('a_name', '/* source code */', 'c', @compiler)
  end

  it "should put designated source code into source file" do
    SOURCE_CODE = "/* some code */\nint main() { return 0; }\n"
    @compiler.should_receive(:oneliner) do |source, target|
      IO.read(source).should == SOURCE_CODE 
      true
    end

    try_compile_and_run('name', SOURCE_CODE, 'c', @compiler)
  end

  it "should remove generated files upon return" do
    @compiler.should_receive(:oneliner) do |source, target|
      @source = source
      @target = target

      true
    end

    try_compile_and_run('name', "/**/", 'c', @compiler)

    File.exists?(@source).should_not == true
    File.exists?(@target).should_not == true
  end

  it "should return false if compiler failed" do
    @compiler.should_receive(:oneliner).once.and_return(false)

    try_compile_and_run('name', '', 'c', @compiler).should == false
  end

  it "should return false if compiler succeeded, but no target found" do
    @compiler.should_receive(:oneliner).once.and_return(true)

    try_compile_and_run('name', '', 'c', @compiler).should == false
  end
end
