class ParsonsExerciseRepresenter < Representable::Decorator
    include Representable::Hash
  
    collection_representer instance: lambda { |options|
      fragment = options[:fragment]
      if fragment.has_key? 'external_id'
        e = Exercise.where(external_id: fragment['external_id']).first
        e || Exercise.new
      else
        Exercise.new
      end
    }
  
    property :name
    property :external_id
    property :is_public, setter: lambda { |val, *| self.is_public = val.to_b }
    property :experience
    property :language_list, getter: lambda { |*| language_list.to_s }
    property :style_list, getter: lambda { |*| style_list.to_s }
    property :tag_list, getter: lambda { |*| tag_list.to_s }
  
    property :current_version, class: ExerciseVersion, setter: lambda { |val, *|
      self.current_version = val
      self.exercise_versions << self.current_version
      self.current_version.exercise = self
    }, instance: lambda { |*| ExerciseVersion.new } do
      property :version, setter: lambda { |*| }
      property :creator, getter: lambda { |*| creator.andand.email }, setter: lambda { |val, *|
        if val
          self.creator = User.where(email: val).first
        end
      }
  
      property :starter_code, getter: lambda { |*|
        files = assets_code_starter_files
        content = files.map { |file| file['content'] }.join('\n') if files
        content
      }
  
      property :test_code, getter: lambda { |*|
        files = assets_test_files
        content = files['content'] if files
        content
      }
    end
  end