import pythy

# -------------------------------------------------------------
class %{class_name}Test(pythy.TestCase):

    # -------------------------------------------------------------
    def setUp(self):
        if not hasattr(self, '%{method_name}'):
            (self.mylocals, self.output) = self.runFile('%{class_name}.py')
            self.__%{method_name} = self.mylocals['%{method_name}']

%{tests}
