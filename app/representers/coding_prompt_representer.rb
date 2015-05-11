require 'representable/hash'
class CodingPromptRepresenter < Representable::Decorator
  include Representable::Hash

  self.representation_wrap = :coding_prompt

  property :position
  property :question
  property :feedback
  property :class_name
  property :method_name
  property :starter_code
  property :wrapper_code
  property :test_script, as: :tests

end
