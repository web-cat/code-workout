# == Schema Information
#
# Table name: workout_policies
#
#  id                                      :bigint           not null, primary key
#  hide_compilation_feedback_before_finish :boolean          default(FALSE), not null
#  hide_feedback_before_finish             :boolean          default(FALSE), not null
#  hide_feedback_in_review_before_close    :boolean          default(FALSE), not null
#  hide_score_before_finish                :boolean          default(FALSE), not null
#  hide_score_in_review_before_close       :boolean          default(FALSE), not null
#  hide_thumbnails_before_start            :boolean          default(FALSE), not null
#  hide_thumbnails_in_review_before_close  :boolean          default(FALSE), not null
#  invisible_before_review                 :boolean          default(FALSE), not null
#  no_faq                                  :boolean          default(FALSE), not null
#  no_hints                                :boolean          default(FALSE), not null
#  no_review_before_close                  :boolean          default(FALSE), not null
#  see_answers                             :boolean          default(TRUE), not null
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#

class WorkoutPolicy < ApplicationRecord
  has_many :workout_offerings, inverse_of: :workout_policy, dependent: :nullify
end
