#!/usr/bin/env ruby
require_relative '%{class_name}'
require 'test/unit'

class %{class_name}Test < Test::Unit::TestCase
	@@f = File.open("results.csv","w")
	      
	def setup
	  @@f.close unless @@f.closed?
	  @@f = File.open("results.csv","a")
          @@obj = %{class_name}.new
	end

	def teardown
	  @@f.close
	end

        %{tests}

end
