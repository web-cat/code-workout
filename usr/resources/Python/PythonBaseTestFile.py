#!/usr/bin/env python
import unittest
import baseclassclass

class baseclassclassTest(unittest.TestCase):
	f=open('baseclassclass_Python_results.csv','w') 
	@classmethod
	def setUpClass(cls):
	  pass
	    
	@classmethod
	def tearDownClass(cls):
	  baseclassclassTest.f.close()
	
	def setUp(self):
	  pass


TTTTT


if __name__ == '__main__':
  unittest.main()



