#! /usr/bin/env ruby
require 'rake'

task :default => :test

task :test do
	Dir.chdir 'test'

	sh 'rspec namedic_spec.rb --color --format doc'
end
