# Can't enable these next two lines, even though formtastic wants them,
# because they break formtastic-boostrap (enabled the third line).
# Will have to wait for formtastic-bootstrap to support the newer version of
# formtastic, which it currently does not (!), but we have to use the
# newer version anyway in order to meet active-admin's requirements.
# -----
Formtastic::FormBuilder.action_class_finder = Formtastic::ActionClassFinder
Formtastic::FormBuilder.input_class_finder = Formtastic::InputClassFinder

# Turn on formtastic-bootstrap
Formtastic::Helpers::FormHelper.builder = FormtasticBootstrap::FormBuilder
