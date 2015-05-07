# == Schema Information
#
# Table name: exercises
#
#  id                 :integer          not null, primary key
#  question_type      :integer          not null
#  current_version_id :integer
#  created_at         :datetime
#  updated_at         :datetime
#  versions           :integer          not null
#  exercise_family_id :integer
#  name               :string(255)
#  is_public          :boolean          default(FALSE), not null
#  experience         :integer          not null
#  irt_data_id        :integer
#  external_id        :string(255)
#
# Indexes
#
#  index_exercises_on_current_version_id  (current_version_id)
#  index_exercises_on_exercise_family_id  (exercise_family_id)
#  index_exercises_on_external_id         (external_id) UNIQUE
#

FactoryGirl.define do
  factory :exercise do
    name 'Factorial'
    question_type { Exercise::Q_CODING }
    is_public true
    experience 50

    # tags: Java, factorial, multiplication, function

    factory :coding_exercise do
      ignore do
        creator_id 1
        question "Write a function in Java called `factorial()` that will "\
          "take a\npositive integer as input and returns its factorial as "\
          "output.\n"
        feedback "Explanation for the correct answer goes here.  This is "\
          "just\nan example.\n"
        class_name 'Factorial'
        method_name 'factorial'
        starter_code "public int factorial(int n)\n"\
          "{\n"\
          "    ___\n"\
          "}\n"
        wrapper_code "public class Factorial\n"\
          "{\n"\
          "    ___\n"\
          "}\n"
        test_script ""\
          "0,1,factorial(0) -> 1\n"\
          "1,1,factorial(1) -> 1\n"\
          "2,2,factorial(2) -> 2\n"\
          "3,6,factorial(3) -> 6\n"\
          "4,24,hidden\n"\
          "5,120,hidden\n"
      end

      versions 1
      question_type { Exercise::Q_CODING }
      language_list 'Java'
      tag_list 'factorial, function, multiplication'
      style_list 'code writing'

      after :create do |e, v|
        e.current_version = FactoryGirl.create :exercise_version,
          exercise: e,
          position: 0,
          creator_id: v.creator_id
        FactoryGirl.create :coding_prompt,
          exercise_version: e.current_version,
          question: v.question,
          feedback: v.feedback,
          class_name: v.class_name,
          method_name: v.method_name,
          starter_code: v.starter_code,
          wrapper_code: v.wrapper_code,
          test_script: v.test_script,
          position: 0
        e.save!
      end
    end
  end
end
