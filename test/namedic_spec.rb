#! /usr/bin/env ruby
require 'rubygems'
require 'namedic'

describe 'namedic' do
  before do
    namedic :a, :b, :optional => [:b]
    def lol (a, b=nil)
      [a, b]
    end
  end

  it 'works with simple namification' do
    lol(2).should == lol(:a => 2)
  end
end
