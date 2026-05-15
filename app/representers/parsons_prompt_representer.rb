require 'representable/hash'
class ParsonsPromptRepresenter < Representable::Decorator
  include Representable::Hash

  self.representation_wrap = :parsons_prompt

  property :position
  property :question
  property :pif_json
  property :wrapper_code
  property :test_script
  property :starter_code
  property :class_name
  property :method_name
end
