# == Schema Information
#
# Table name: exercises
#
#  id                     :integer          not null, primary key
#  experience             :integer          not null
#  is_public              :boolean          default(FALSE), not null
#  name                   :string(255)
#  question_type          :integer          not null
#  versions               :integer
#  created_at             :datetime
#  updated_at             :datetime
#  current_version_id     :integer
#  exercise_collection_id :integer
#  exercise_family_id     :integer
#  external_id            :string(255)
#  irt_data_id            :integer
#
# Indexes
#
#  exercises_irt_data_id_fk                   (irt_data_id)
#  index_exercises_on_current_version_id      (current_version_id)
#  index_exercises_on_exercise_collection_id  (exercise_collection_id)
#  index_exercises_on_exercise_family_id      (exercise_family_id)
#  index_exercises_on_external_id             (external_id) UNIQUE
#  index_exercises_on_is_public               (is_public)
#
# Foreign Keys
#
#  exercises_current_version_id_fk  (current_version_id => exercise_versions.id)
#  exercises_exercise_family_id_fk  (exercise_family_id => exercise_families.id)
#  exercises_irt_data_id_fk         (irt_data_id => irt_data.id)
#

FactoryBot.define do
  sequence :exercise_no, 1
  factory :exercise do
    transient do
      num { generate :exercise_no }
    end
    external_id { 'E' + num.to_s }
    name { 'Factorial ' + num.to_s }
    question_type { Exercise::Q_CODING }
    is_public { true }
    experience { 50 }

    # tags: Java, factorial, multiplication, function

    factory :coding_exercise do
      transient do
        creator_id { 1 }
        question { "Write a function in Java called `factorial()` that will "\
          "take a\npositive integer as input and returns its factorial as "\
          "output.\n" }
        feedback { "Explanation for the correct answer goes here.  This is "\
          "just\nan example.\n" }
        class_name { 'Factorial' }
        method_name { 'factorial' }
        starter_code { "public int factorial(int n)\n"\
          "{\n"\
          "    ___\n"\
          "}\n" }
        wrapper_code { "public class Factorial\n"\
          "{\n"\
          "    ___\n"\
          "}\n" }
        test_script { ""\
          "0,1\n"\
          "1,1\n"\
          "2,2\n"\
          "3,6\n"\
          "4,24,hidden\n"\
          "5,120,hidden\n" }
      end

      question_type { Exercise::Q_CODING }
      language_list { 'Java' }
      tag_list { 'factorial, function, multiplication' }
      style_list { 'code writing' }

      after :create do |e, v|
        e.current_version = FactoryBot.create :exercise_version,
          exercise: e,
          creator_id: v.creator_id
        e.exercise_versions << e.current_version
        FactoryBot.create :coding_prompt,
          exercise_version: e.current_version,
          question: v.question,
          feedback: v.feedback,
          class_name: v.class_name,
          method_name: v.method_name,
          starter_code: v.starter_code,
          wrapper_code: v.wrapper_code,
          test_script: v.test_script
        e.save!
      end
    end

    factory :mc_exercise do
      transient do
        creator_id { 1 }
        question { "This is a sample multiple choice question.  It has only "\
          "one correct answer.\n" }
        feedback { "Explanation for the correct answer goes here.  This is "\
          "just\nan example.\n" }
      end

      name { 'Pick One ' + num.to_s }
      question_type { Exercise::Q_MC }
      tag_list { 'random' }
      style_list { 'forced choice' }

      after :create do |e, v|
        e.current_version = FactoryBot.create :exercise_version,
          exercise: e,
          creator_id: v.creator_id
        e.exercise_versions << e.current_version
        FactoryBot.create :mc_with_choices,
          exercise_version: e.current_version,
          question: v.question,
          feedback: v.feedback
        e.save!
      end
    end
  end
end
