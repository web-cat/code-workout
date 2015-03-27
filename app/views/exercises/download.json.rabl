collection @exercises

attribute :id => :exid
attributes :question, :is_public, :priority, :experience
node(:name) { |exercise| exercise.read_attribute(:name)  }
child(:stem) { attributes :preamble }

node :user_id do |exercise|
  exercise.user ? exercise.user.id : exercise.base_exercise.user.andand.id
end

node :variation_group do |exercise|
  exercise.base_exercise.variation_group.andand.name
end

attribute :feedback => :explanation

node :tags do |exercise|
  if exercise.tags.size > 0
    exercise.tags.map {|t| t.tag_name}.join(', ')
  end
end

attribute :language => :programming_language
attribute :mcq_allow_multiple, if: lambda { |e| e.base_exercise.is_mcq? }
attribute :mcq_is_scrambled, if: lambda { |e| e.base_exercise.is_mcq? }
child :choices, if: lambda { |e| e.base_exercise.is_mcq? } do
  attributes :answer, :order, :value, :feedback
end

child :coding_question, if: lambda { |e| e.base_exercise.is_coding? } do
  attributes :class_name, :method_name, :starter_code, :wrapper_code
  attribute :test_script => :tests
end
