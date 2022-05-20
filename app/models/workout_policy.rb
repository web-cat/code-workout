# == Schema Information
#
# Table name: workout_policies
#
#  id                                      :integer          not null, primary key
#  description                             :string(255)
#  hide_compilation_feedback_before_finish :boolean
#  hide_feedback_before_finish             :boolean
#  hide_feedback_in_review_before_close    :boolean
#  hide_score_before_finish                :boolean
#  hide_score_in_review_before_close       :boolean
#  hide_thumbnails_before_start            :boolean
#  hide_thumbnails_in_review_before_close  :boolean
#  invisible_before_review                 :boolean
#  name                                    :string(255)
#  no_faq                                  :boolean
#  no_hints                                :boolean
#  no_review_before_close                  :boolean
#  created_at                              :datetime
#  updated_at                              :datetime
#

class WorkoutPolicy < ActiveRecord::Base
  has_many :workout_offerings, inverse_of: :workout_policy, dependent: :nullify
end
