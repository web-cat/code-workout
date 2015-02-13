#!/usr/bin/env python
import unittest
import Fibonacci

class FibonacciTest(unittest.TestCase):
  f=open('Fibonacci_Python_results.csv','w') 
  @classmethod
  def setUpClass(cls):
    pass
    
  @classmethod
  def tearDownClass(cls):
    FibonacciTest.f.close()

  def setUp(self):
    pass

  def test_1(self):
    if Fibonacci.fibonacciChecker(1)==True:
      FibonacciTest.f.write("1,,1\n")
    else:
      FibonacciTest.f.write("0,Unsuccessful normal Fibonacci generation,1\n")
    self.assertEqual(Fibonacci.fibonacciChecker(1),True)

  def test_3(self):
    if Fibonacci.fibonacciChecker(3)==True:
      FibonacciTest.f.write("1,,2\n")
    else:
      FibonacciTest.f.write("0,Unsuccessful Fibonacci false positive detection,2\n")
    self.assertEqual(Fibonacci.fibonacciChecker(3),True)

  def test_6(self):
    if Fibonacci.fibonacciChecker(6)==True:
      FibonacciTest.f.write("1,,3\n")
    else:
      FibonacciTest.f.write("0,Large Fibonacci failue,3\n")
    self.assertEqual(Fibonacci.fibonacciChecker(6),True)

  def test_9(self):
    if Fibonacci.fibonacciChecker(9)==True:
      FibonacciTest.f.write("1,,4\n")
    else:
      FibonacciTest.f.write("0,Unsuccessful normal Fibonacci generation,4\n")
    self.assertEqual(Fibonacci.fibonacciChecker(9),True)

  def test_13(self):
    if Fibonacci.fibonacciChecker(13)==True:
      FibonacciTest.f.write("1,,5\n")
    else:
      FibonacciTest.f.write("0,Unsuccessful Fibonacci false positive detection,5\n")
    self.assertEqual(Fibonacci.fibonacciChecker(13),True)

  def test_15(self):
    if Fibonacci.fibonacciChecker(15)==False:
      FibonacciTest.f.write("1,,6\n")
    else:
      FibonacciTest.f.write("0,Large Fibonacci failue,6\n")
    self.assertEqual(Fibonacci.fibonacciChecker(15),False)

  def test_21(self):
    if Fibonacci.fibonacciChecker(21)==True:
      FibonacciTest.f.write("1,,7\n")
    else:
      FibonacciTest.f.write("0,Large Fibonacci failue,7\n")
    self.assertEqual(Fibonacci.fibonacciChecker(21),True)

if __name__ == '__main__':
  unittest.main()



