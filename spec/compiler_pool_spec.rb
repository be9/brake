require File.dirname(__FILE__) + '/spec_helper'

require 'compiler_pool'

describe Brake::CompilerPool do
  before do
    @pool = Brake::CompilerPool.new
  end

  it "should load compiler" do
    @pool.compiler :gcc
    @pool.loaded?(:gcc).should == true
    @pool.loaded?("gcc").should == true
  end
end
