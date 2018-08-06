#!/usr/bin/env python
import unittest
import Factorial

class FactorialTest(unittest.TestCase):
  f=open('Factorial_Python_results.csv','w') 
  @classmethod
  def setUpClass(cls):
    pass
    
  @classmethod
  def tearDownClass(cls):
    FactorialTest.f.close()

  def setUp(self):
    pass

  def test_1(self):
    if Factorial.factorial(1)==1:
      FactorialTest.f.write("1,,1\n")
    else:
      FactorialTest.f.write("0,Unsuccessful normal factorial generation,1\n")
    self.assertEqual(Factorial.factorial(1),1)

  def test_2(self):
    if Factorial.factorial(2)==2:
      FactorialTest.f.write("1,,2\n")
    else:
      FactorialTest.f.write("0,Zero factorial generation improper,2\n")
    self.assertEqual(Factorial.factorial(2),2)

  def test_3(self):
    if Factorial.factorial(3)==3:
      FactorialTest.f.write("1,,3\n")
    else:
      FactorialTest.f.write("0,3 factorial failue,3\n")
    self.assertEqual(Factorial.factorial(3),3)

  def test_4(self):
    if Factorial.factorial(4)==24:
      FactorialTest.f.write("1,,4\n")
    else:
      FactorialTest.f.write("0,Unsuccessful normal factorial generation,4\n")
    self.assertEqual(Factorial.factorial(4),24)

  def test_0(self):
    if Factorial.factorial(0)==1:
      FactorialTest.f.write("1,,5\n")
    else:
      FactorialTest.f.write("0,Zero factorial generation improper,5\n")
    self.assertEqual(Factorial.factorial(0),1)

  def test_7(self):
    if Factorial.factorial(7)==5040:
      FactorialTest.f.write("1,,6\n")
    else:
      FactorialTest.f.write("0,Large factorial failue,6\n")
    self.assertEqual(Factorial.factorial(7),5040)

if __name__ == '__main__':
  unittest.main()



