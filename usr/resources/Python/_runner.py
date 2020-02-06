import sys
import os
sys.path.insert(0, '/resources/lib')
sys.path.append('.')

import pythy

import os

for module in os.listdir('.'):
  if module[-7:] != 'Test.py':
    continue
  __import__(module[:-3], locals(), globals())
del module

sys.path.pop()

with open('results.csv', 'w') as f:
  pythy.runAllTests(f)
