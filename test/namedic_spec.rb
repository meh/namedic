#! /usr/bin/env ruby
require 'rubygems'
require 'namedic'
require 'ap'

class LOL
  singleton_namedic :a, :b, :optional => [:b]
  def self.omg (a, b=nil)
    [a, b]
  end
end

describe Namedic do
  it 'works with explicit class notification' do
    LOL.omg(2, 3).should == LOL.omg(:a => 2, :b => 3)
  end
end
