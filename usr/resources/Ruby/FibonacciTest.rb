#!/usr/bin/env ruby
require_relative 'Fibonacci'
require 'test/unit'

class FibonacciTest < Test::Unit::TestCase
      @@f = File.open("Fibonacci_Ruby_results.csv","w")
      
  def setup
      @@f.close unless @@f.closed?
      @@f = File.open("Fibonacci_Ruby_results.csv","a")
  end

  def teardown
    @@f.close
  end

  def testFibonacci1
    if fibonacciChecker(1)==true
      @@f.write("1,,1\n")   
    else
      @@f.write("0,Simple Fibonacci test failed,1\n")
    end
    assert_equal(fibonacciChecker(1),true)
  end

  def testFibonacci3
    if fibonacciChecker(3)==true
      @@f.write("1,,2\n")   
    else
      @@f.write("0,Simple Fibonacci falsification test failed,2\n")
    end
    assert_equal(fibonacciChecker(3),true)
  end

  def testFibonacci6
    if fibonacciChecker(6)==false
      @@f.write("1,,3\n")   
    else
      @@f.write("0,Large Fibonacci test failed Fibonacci test failed,3\n")
    end
    assert_equal(fibonacciChecker(6),false)
  end  


  def testFibonacci9
    if fibonacciChecker(9)==false
      @@f.write("1,,4\n")   
    else
      @@f.write("0,Simple Fibonacci test failed,4\n")
    end
    assert_equal(fibonacciChecker(9),false)
  end

  def testFibonacci13
    if fibonacciChecker(13)==false
      @@f.write("1,,5\n")   
    else
      @@f.write("0,Simple Fibonacci falsification test failed,5\n")
    end
    assert_equal(fibonacciChecker(13),false)
  end

  def testFibonacci15
    if fibonacciChecker(15)==false
      @@f.write("1,,6\n")   
    else
      @@f.write("0,Large Fibonacci test failed Fibonacci test failed,6\n")
    end
    assert_equal(fibonacciChecker(15),false)
  end  

  def testFibonacci21
    if fibonacciChecker(21)==true
      @@f.write("1,,7\n")   
    else
      @@f.write("0,Large Fibonacci test failed Fibonacci test failed,7\n")
    end
    assert_equal(fibonacciChecker(21),true)
  end  



end
