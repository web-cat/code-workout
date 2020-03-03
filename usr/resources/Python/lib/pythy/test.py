"""Test case implementation."""

import io
import unittest
import traceback
import sys
# import yaml
import json
import re
import threading
import ctypes
import time


#~ Sandbox overrides ..........................................................

_originalBuiltins = {}

# -------------------------------------------------------------
def _disabled_compile(source, filename, mode, flags=0, dont_inherit=False):
  raise RuntimeError("You are not allowed to call 'compile'.")

# -------------------------------------------------------------
def _disabled_eval(object, globals=globals(), locals=locals()):
  raise RuntimeError("You are not allowed to call 'eval'.")

# -------------------------------------------------------------
def _disabled_exec(object, globals=globals(), locals=locals()):
  raise RuntimeError("You are not allowed to call 'exec'.")

# -------------------------------------------------------------
def _disabled_globals():
  raise RuntimeError("You are not allowed to call 'globals'.")

# -------------------------------------------------------------
_open_forbidden_names = re.compile(r"(^[./])|(\.py$)")
_open_forbidden_modes = re.compile(r"[wa+]")

def _restricted_open(name, mode='r', buffering=-1):
  if _open_forbidden_names.search(name):
    raise RuntimeError('The filename you passed to \'open\' is restricted.')
  elif _open_forbidden_modes.search(mode):
    raise RuntimeError('You are not allowed to \'open\' files for writing.')
  else:
    return _originalBuiltins['open'](name, mode, buffering)


_reject_traceback_file_pattern = re.compile(r'[./]')



#~ Global functions ...........................................................

# -------------------------------------------------------------
def timeout(duration, func, *args, **kwargs):
  """
  Executes a function and kills it (throwing an exception) if it runs for
  longer than the specified duration, in seconds.
  """

  # -------------------------------------------------------------
  class InterruptableThread(threading.Thread):

    # -------------------------------------------------------------
    def __init__(self):
      threading.Thread.__init__(self)
      self.daemon = True
      self.result = None
      self.exc_info = (None, None, None)

    
    # -------------------------------------------------------------
    def run(self):
      try:
        self.result = func(*args, **kwargs)
      except Exception as e:
        self.exc_info = sys.exc_info()

    
    # -------------------------------------------------------------
    @classmethod
    def _async_raise(cls, tid, excobj):
      res = ctypes.pythonapi.PyThreadState_SetAsyncExc( \
        ctypes.c_long(tid), ctypes.py_object(excobj))
        
      if res == 0:
        raise ValueError("nonexistent thread id")
      elif res > 1:
        ctypes.pythonapi.PyThreadState_SetAsyncExc(tid, 0)
        raise SystemError("PyThreadState_SetAsyncExc failed")


    # -------------------------------------------------------------
    def raise_exc(self, excobj):
      assert self.isAlive(), "thread must be started"
      for tid, tobj in threading._active.items():
        if tobj is self:
          self._async_raise(tid, excobj)
          return


    # -------------------------------------------------------------
    def terminate(self):
      self.raise_exc(SystemExit)

  target_thread = InterruptableThread()
  target_thread.start()
  target_thread.join(duration)

  if target_thread.isAlive():
    target_thread.terminate()
    raise TimeoutError('Your code took too long to run '
      '(it was given {} seconds); '
      'maybe you have an infinite loop?'.format(duration))
  else:
    if target_thread.exc_info[0] is not None:
      ei = target_thread.exc_info
      # Python 2 had the three-argument raise statement; thanks to PEP 3109
      # for showing how to convert that to valid Python 3 statements.
      e = ei[0](ei[1])
      e.__traceback__ = ei[2]
      raise e


# -------------------------------------------------------------
def runAllTests(stream=sys.stderr,timeoutCeiling=2.5):
  """
  Runs all test cases in suites that extend pythy.TestCase.
  """

  global _timeoutData
  _timeoutData = _TimeoutData(timeoutCeiling)

  _recursivelyRunTests(TestCase, stream)


# -------------------------------------------------------------
def _recursivelyRunTests(cls, stream):
  for child in cls.__subclasses__():
    suite = unittest.TestLoader().loadTestsFromTestCase(child)
    TestRunner(stream).run(suite)
    _recursivelyRunTests(child, stream)



#~ Decorators .................................................................

# -------------------------------------------------------------
def category(catname):
  """
  Specifies a category for a test case, which will be written in the
  result output.
  """
  def decorator(test_item):
    test_item.__pythytest_category__ = catname
    return test_item
  return decorator



#~ Classes ....................................................................

# =========================================================================
class TimeoutError(Exception):
  """
  Thrown by a test case if it exceeds the allowed amount of execution time.
  """
  pass


# =========================================================================
class _TimeoutData:
  """
  Port of Craig Estep's AdaptiveTimeout JUnit rule from the VTCS student
  library.
  """
  
  # -------------------------------------------------------------
  def __init__(self, ceiling):
    self.ceiling = ceiling # sec
    self.maximum = ceiling * 2 # sec
    self.minimum = 0.1 # sec
    self.threshold = 0.6
    self.rampup = 1.4
    self.rampdown = 0.5
    self.start = self.end = 0
    self.nonterminatingMethods = 0

  
  # -------------------------------------------------------------
  def beforeTest(self):
    """
    Call this before a test case runs in order to reset the timer.
    """
    self.start = time.time()


  # -------------------------------------------------------------
  def afterTest(self):
    """
    Call this after a test case runs. This will examine how long it took
    the test to execute, and if it required an amount of time greater than
    the current ceiling, it will adaptively adjust the allowed time for
    the next test.
    """
    self.end = time.time()
    diff = self.end - self.start

    if diff > self.ceiling:
      self.nonterminatingMethods += 1

      if self.nonterminatingMethods >= 2:
        if self.ceiling * self.rampdown < self.minimum:
          self.ceiling = self.minimum
        else:
          self.ceiling = (self.ceiling * self.rampdown)
    elif diff > self.ceiling * self.threshold:
      if self.ceiling * self.rampup > self.maximum:
        self.ceiling = self.maximum
      else:
        self.ceiling = (self.ceiling * self.rampup)



# =========================================================================
class TestCase(unittest.TestCase):

  # -------------------------------------------------------------
  def __init__(self, methodName='runTest'):
    unittest.TestCase.__init__(self, methodName)


  # -------------------------------------------------------------
  def run(self, testMethod):
    # Dynamically wraps test method in timeout() before calling super,
    # then unwraps it in finally clause.
    __tm = getattr(self, self._testMethodName)
    def __tm_protected():
      timeout(_timeoutData.ceiling, __tm)
    setattr(self, self._testMethodName, __tm_protected)

    # Also performs callbacks on timeout data object.
    _timeoutData.beforeTest()

    try:
      unittest.TestCase.run(self, testMethod)
    finally:
      _timeoutData.afterTest()
      setattr(self, self._testMethodName, __tm)      


  # -------------------------------------------------------------
  def runFile(self, filename='main.py', input=''):
    """
    Runs the Python code in the specified file (if omitted, main.py is
    used) under a restricted environment, using the specified input string
    as the content of stdin and capturing the text sent to stdout.

    Returns a 2-tuple (studentLocals, output), where studentLocals is a
    dictionary containing the state of the local variables, functions, and
    class definitions after the program was executed, and output is the
    text that the program wrote to stdout.

    """
    self.__overrideBuiltins({
      'compile':  _disabled_compile,
      'eval':     _disabled_eval,
      'exec':     _disabled_exec,
      'globals':  _disabled_globals,
      'open':     _restricted_open
    })

    studentLocals = self.safeGlobals

    captureout = io.StringIO()
    injectin = io.StringIO(input)

    oldstdout = sys.stdout
    oldstdin = sys.stdin

    sys.stdout = captureout
    sys.stdin = injectin

    try:
      # Calling compile instead of just passing the string source to exec
      # ensures that we get meaningul filenames in the traceback when tests
      # fail or have errors.
      with open(filename, 'r') as fh:
        code = fh.read() + '\n'

      code = "import pythy.sandbox\n" + code

      codeObject = compile(code, filename, 'exec')
      exec(codeObject, self.safeGlobals, studentLocals)
    finally:
      sys.stdout = oldstdout
      sys.stdin = oldstdin

    return (studentLocals, captureout.getvalue())


  # -------------------------------------------------------------
  def captureOutput(self, fn):
    captureout = io.StringIO()
    oldstdout = sys.stdout
    sys.stdout = captureout
    try:
      fn()
      return captureout.getvalue()
    finally:
      sys.stdout = oldstdout


  # -------------------------------------------------------------
  def __overrideBuiltins(self, dictionary):
    # Create a shallow copy of the dictionary of built-in methods. Then,
    # we'll take specific ones that are unsafe and replace them.
    self.safeGlobals = {}
    safeBuiltins = self.safeGlobals["__builtins__"] = __builtins__.copy()

    for name, function in dictionary.items():
      _originalBuiltins[name] = __builtins__[name]
      safeBuiltins[name] = function

  def assertSoundsSimilar(self, expected, actual):
    length = actual.getLength()

    self.assertEqual(expected.getLength(), length)

    ALLOWABLE_ERROR = 0

    for i in range(length):
      actualSample = actual.getSampleValueAt(i)
      expectedSample = expected.getSampleValueAt(i)

      if abs(actualSample - expectedSample) > ALLOWABLE_ERROR:
        self.fail('Some samples do not have the expected values')

  # --------------------------------------------------------------
  def assertImagesSimilar(self, reason, expected, actual):
    width = actual.getWidth()
    height = actual.getHeight()

    self.assertEqual(expected.getWidth(), width, \
      reason + ", the width of your final image was incorrect.")
    self.assertEqual(expected.getHeight(), height, \
      reason + ", the height of your final image was incorrect.")

    ALLOWABLE_ERROR = 1

    red_errors = False
    green_errors = False
    blue_errors = False

    # Compare the pixels in the student's image and the correct image,
    # using the tolerance above. Keep track of which color channels
    # contained incorrect values.

    for r in range(height):
      for c in range(width):
        actualpixel = actual.getPixel(c, r)
        expectedpixel = expected.getPixel(c, r)

        if abs(actualpixel.getRed() - expectedpixel.getRed()) > ALLOWABLE_ERROR:
          red_errors = True

        if abs(actualpixel.getGreen() - expectedpixel.getGreen()) > ALLOWABLE_ERROR:
          green_errors = True

        if abs(actualpixel.getBlue() - expectedpixel.getBlue()) > ALLOWABLE_ERROR:
          blue_errors = True

    channels = ''

    # Construct a hint message based on which color channels, if any,
    # had incorrect values.

    if red_errors:
      channels = 'red'

      if green_errors:
        if blue_errors:
          channels += ', green, and blue components'
        else:
          channels += ' and green components'
      elif blue_errors:
        channels += ' and blue components'
      else:
        channels += ' components'
    elif green_errors:
      channels += 'green'

      if blue_errors:
        channels += ' and blue components'
      else:
        channels += ' components'
    elif blue_errors:
      channels += 'blue components'

    if len(channels) > 0:
      self.fail('The ' + channels + ' contained some incorrect values.')

# =========================================================================
class TestRunner:

  # -------------------------------------------------------------
  def __init__(self, stream=sys.stderr):
    self.stream = stream
    self.testData = {
      'categories': set(),
      'tests': []
    }


  # -------------------------------------------------------------
  def run(self, test):
    result = _PythyTestResult(self)
    test(result)
    self.__dumpOutcomes()
    return result


  # -------------------------------------------------------------
  def __dumpOutcomes(self):
    # Convert the 'categories' set to a list so that it gets dumped cleanly
    # in the YAML output.
    self.testData['categories'] = list(self.testData['categories'])

    # yaml.dump(self.testData, self.stream, default_flow_style=False)
    # json.dump(self.testData, self.stream)
    for data in self.testData['tests']:
        # print CSV format
        # json.dump(data, self.stream)
        name = data['name'].split('.')
        tc = name.pop()
        self.stream.write('/attempt,')
        self.stream.write('.'.join(name))
        self.stream.write(',')
        self.stream.write(tc)
        self.stream.write(',0,0,')
        if 'exception' in data:
            self.stream.write(data['exception'])
        else:
            self.stream.write('null')
        self.stream.write(',')
        if 'message' in data:
            self.stream.write('"')
            self.stream.write(data['message'])
            self.stream.write('"')
        else:
            self.stream.write('null')
        self.stream.write(',')
        if data['result'] == 'success':
            self.stream.write("1\n")
        else:
            self.stream.write("0\n")
    self.stream.flush()


  # -------------------------------------------------------------
  def _startTest(self, test):
    newtest = { 'name': test.id() }

    #print "dumping properties for test method"
    #for property, value in vars(testMethod).iteritems():
    #  print property, ": ", value
    #print "\n"
    
    if test.shortDescription():
      newtest["description"] = test.shortDescription()

    testMethod = getattr(test, test._testMethodName)

    category = getattr(testMethod, '__pythytest_category__', None)
    if category:
      newtest['category'] = category
      self.testData['categories'].add(category)

    #points = getattr(testMethod, 'points', None)
    #if points:
    #  newtest['points'] = points

    self.testData['tests'].append(newtest)
    return newtest



# =========================================================================
class _PythyTestResult(unittest.TestResult):
  """
  A custom test result class that prints output in Yaml format
  that Pythy's worker process can easily read in and process.
  """

  # -------------------------------------------------------------
  def __init__(self, runner):
    unittest.TestResult.__init__(self)
    self.runner = runner


  # -------------------------------------------------------------
  def startTest(self, test):
    unittest.TestResult.startTest(self, test)
    self.currentTest = self.runner._startTest(test)


  # -------------------------------------------------------------
  def addError(self, test, err):
    unittest.TestResult.addError(self, test, err)
    self.currentTest["result"] = "error"
    self.__populateWithError(err)


  # -------------------------------------------------------------
  def addFailure(self, test, err):
    unittest.TestResult.addFailure(self, test, err)
    self.currentTest["result"] = "failure"
    self.__populateWithError(err)


  # -------------------------------------------------------------
  def addSuccess(self, test):
    unittest.TestResult.addSuccess(self, test)
    self.currentTest["result"] = "success"


  # -------------------------------------------------------------
  def addSkip(self, test, reason):
    unittest.TestResult.addSkip(self, test, reason)


  # -------------------------------------------------------------
  def addExpectedFailure(self, test, err):
    unittest.TestResult.addExpectedFailure(self, test, err)


  # -------------------------------------------------------------
  def addUnexpectedSuccess(self, test):
    unittest.TestResult.addUnexpectedSuccess(self, test)


  # -------------------------------------------------------------
  def stopTest(self, test):
    unittest.TestResult.stopTest(self, test)


  # -------------------------------------------------------------
  def __populateWithError(self, err):
    self.currentTest['exception'] = err[0].__name__
    msg = str(err[1])
    if err[0].__name__ == 'AssertionError':
      self.currentTest['reason'] = msg
    else:
      self.currentTest['reason'] = err[0].__name__ + ': ' + msg
    msg = re.sub(r"(.+) != (.+)", r"Expected \1, but got \2", msg.split('\n')[0])
    msg = re.sub(r'"', r'""', msg)
    self.currentTest['message'] = msg

    # Reject tracebacks that are absolute paths or dot-leading paths;
    # most of these are going to be internal unittest or Python noise
    # anyway.
    tbList = traceback.extract_tb(err[2])
    tbList = filter(lambda frame: \
      not _reject_traceback_file_pattern.match(frame[0]), tbList)

    frames = list(map(lambda frame: "{2} ({0}:{1})".format(*frame), tbList))
    frameCount = min(len(frames), 20)
    self.currentTest['traceback'] = frames[0:frameCount]
