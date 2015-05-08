require 'representable/hash'
class ExerciseRepresenter < Representable::Decorator
  include Representable::Hash

  collection_representer class: Exercise


  property :name
  property :external_id
  property :is_public
  property :experience
  property :language_list, getter: lambda { |*| language_list.to_s }
  property :style_list, getter: lambda { |*| style_list.to_s }
  property :tag_list, getter: lambda { |*| tag_list.to_s }
  property :version, getter: lambda { |*| versions - 1 }
  property :creator,
    getter: lambda { |*| current_version.creator.andand.email }
  property :stem, getter: lambda { |*| current_version.stem }
  collection :prompts,
    getter: lambda { |*| current_version.prompts.map(&:specific) },
    class: lambda { |hsh, *|
      hsh.has_key?('coding_prompt') ?
        CodingPrompt : MultipleChoicePrompt },
    decorator: lambda { |o, *|
      o.is_a?(CodingPrompt) ?
        CodingPromptRepresenter : MultipleChoicePromptRepresenter }

end
