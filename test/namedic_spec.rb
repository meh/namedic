#! /usr/bin/env ruby
require 'rubygems'
require 'namedic'

class LOL
  singleton_namedic :a, :b, :optional => [:b]
  def self.omg (a, b=nil)
    [a, b]
  end

  namedic def lol (a)
    a
  end
end

describe Namedic do
  it 'works with explicit class notification' do
    LOL.omg(2, 3).should == LOL.omg(:a => 2, :b => 3)
  end

  it 'works with auto namedification' do
    LOL.new.lol(:a => 2).should == LOL.new.lol(2)
  end
end
