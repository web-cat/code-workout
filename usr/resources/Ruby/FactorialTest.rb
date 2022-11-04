#!/usr/bin/env ruby
require_relative 'Factorial'
require 'test/unit'

class FactorialTest < Test::Unit::TestCase
      @@f = File.open("Factorial_Ruby_results.csv","w")
      
  def setup
      @@f.close unless @@f.closed?
      @@f = File.open("Factorial_Ruby_results.csv","a")
  end

  def teardown
    @@f.close
  end

  def testFactorial1
    if factorial(1)==1
      @@f.write("1,,1\n")   
    else
      @@f.write("0,Simple Factorial test failed,1\n")
    end
    assert_equal(factorial(1),1)
  end

  def testFactorial2
    if factorial(2)==2
      @@f.write("1,,2\n")   
    else
      @@f.write("0,Zero Factorial test failed,2\n")
    end
    assert_equal(factorial(2),2)
  end

  def testFactorial3
    if factorial(3)==6
      @@f.write("1,,3\n")   
    else
      @@f.write("0,Simple Factorial falsification test failed,3\n")
    end
    assert_equal(factorial(3),6)
  end

  def testFactorial4
    if factorial(4)==24
      @@f.write("1,,4\n")   
    else
      @@f.write("0,Large Factorial test failed Factorial test failed,4\n")
    end
    assert_equal(factorial(4),24)
  end  

  def testFactorial0
    if factorial(0)==1
      @@f.write("1,,5\n")   
    else
      @@f.write("0,Simple Factorial falsification test failed,5\n")
    end
    assert_equal(factorial(0),1)
  end

  def testFactorial7
    if factorial(7)==5040
      @@f.write("1,,6\n")   
    else
      @@f.write("0,Large Factorial test failed Factorial test failed,6\n")
    end
    assert_equal(factorial(7),5040)
  end 


end
