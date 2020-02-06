import sys
import imp
import re
import io

# =========================================================================
class SandboxedModules:

  # -------------------------------------------------------------
  def __init__(self):
    self._modules = {}

  # -------------------------------------------------------------
  def add_module(self, fullname, funcs):
    self._modules[fullname] = funcs

  # -------------------------------------------------------------
  def find_module(self, fullname, path=None):
    if fullname in self._modules:
      self.path = path
      return self
    else:
      return None

  # -------------------------------------------------------------
  def load_module(self, fullname):
    if fullname in sys.modules:
      return sys.modules[fullname]

    module_info = imp.find_module('request', self.path)
    module = imp.load_module('request', *module_info)

    if fullname == 'urllib.request':
      module.urlopen = call_urlopen

    sys.modules[fullname] = module
    return module


_fixed_currencies = {
  '100:EUR': '{lhs: "100 U.S. dollars",rhs: "75.7002271 Euros",error: "",icc: true}',
  '89.32:GBP': '{lhs: "89.32 U.S. dollars",rhs: "58.4669765 British pounds",error: "",icc: true}',
  '1.0:JPY': '{lhs: "1.00 U.S. dollar",rhs: "93.3096949 Japanese yen",error: "",icc: true}',
  '99:UAH': '{lhs: "99 U.S. dollars",rhs: "805.926408 Ukrainian grivnas",error: "",icc: true}'
}

# -------------------------------------------------------------
def call_urlopen(url):
  return _sandboxed_urlopen(url)


# -------------------------------------------------------------
def set_urlopen(fn):
  global _sandboxed_urlopen
  _sandboxed_urlopen = fn


# -------------------------------------------------------------
def _safe_urlopen(url):
  m = re.match(r"http://www.google.com/ig/calculator\?(?:hl=en&)?q=([0-9.]+)USD=\?(.*)", url)
  if m:
    groups = m.groups()
    amount = groups[0]
    currency = groups[1]
    key = amount + ':' + currency
    if key in _fixed_currencies:
      return io.StringIO(_fixed_currencies[key])
    else:
      return io.StringIO('{lhs: "100 U.S. dollars",rhs: "75.7002271 Euros",error: "",icc: true}')
  elif re.match(r"http://people.cs.vt.edu/allevato/cs2984-python/project2/words.txt", url):
    return io.StringIO('sampleword\n')
  else:
    raise AssertionError('The URL you requested was formatted incorrectly or not allowed.')


def sandboxModule(name, dict):
  _sandbox.add_module(name, dict)


_sandbox = SandboxedModules()
sys.meta_path.insert(0, _sandbox)

urllib_request = {}
urllib_request['urlopen'] = _safe_urlopen

_sandbox.add_module('urllib.request', urllib_request)
