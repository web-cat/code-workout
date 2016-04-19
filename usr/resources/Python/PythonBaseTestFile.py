#!/usr/bin/env python
import unittest
import %{class_name}

class %{class_name}Test(unittest.TestCase):
	f=open('results.csv','w') 
	obj = %{class_name}.%{class_name}()
        @classmethod
	def setUpClass(cls):
	  pass
	    
	@classmethod
	def tearDownClass(cls):
	  %{class_name}Test.f.close()
	
	def setUp(self):
	  pass

%{tests}


if __name__ == '__main__':
  unittest.main()



