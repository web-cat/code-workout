# app/representers/parsons_prompt_representer.rb

class ParsonsPromptRepresenter < Representable::Decorator
  include Representable::Hash

  property :instructions
  property :exercise_id

  property :assets do
    property :code do
      property :starter do
        collection :files do
          property :content, getter: lambda { |*|
            code_blocks = []
            content.each do |block|
              code_blocks << { "tag" => block["tag"], "display" => block["display"] }
            end
            code_blocks
          }, setter: lambda { |val, *|
            self.content = val.map { |block| { "tag" => block["tag"], "display" => block["display"] } }
          }
        end
      end
    end

    property :test do
      collection :files do
        property :content
      end
    end
  end
end