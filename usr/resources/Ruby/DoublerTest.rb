#!/usr/bin/env ruby
require_relative 'Doubler'
require 'test/unit'

class DoublerTest < Test::Unit::TestCase
	@@f = File.open("Doubler_Ruby_results.csv","w")
	      
	def setup
	  @@f.close unless @@f.closed?
	  @@f = File.open("Doubler_Ruby_results.csv","a")
	end

	def teardown
	  @@f.close
	end

	def testDoubler1
		if double(1)==2
			@@f.write("1,,1\n") 
		else
			@@f.write("0,Doubling failure,1\n")
		end
		assert_equal(double(1),2)
	end

	def testDoubler2
		if double(2)==4
			@@f.write("1,,2\n") 
		else
			@@f.write("0,Doubling failure,2\n")
		end
		assert_equal(double(2),4)
	end




end
