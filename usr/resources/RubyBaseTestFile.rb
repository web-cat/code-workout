#!/usr/bin/env ruby
require_relative 'baseclassclass'
require 'test/unit'

class baseclassclassTest < Test::Unit::TestCase
	@@f = File.open("baseclassclass_Ruby_results.csv","w")
	      
	def setup
	  @@f.close unless @@f.closed?
	  @@f = File.open("baseclassclass_Ruby_results.csv","a")
	end

	def teardown
	  @@f.close
	end

TTTTT


end
