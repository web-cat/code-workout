require 'representable/hash'
class MultipleChoicePromptRepresenter < Representable::Decorator
  include Representable::Hash

  self.representation_wrap = :multiple_choice_prompt

  property :question
  property :mcq_allow_multiple
  property :mcq_is_scrambled
  collection :choices, class: Choice do
    property :answer
    property :value
    property :position
    property :feedback
  end

end
