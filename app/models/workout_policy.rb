# == Schema Information
#
# Table name: workout_policies
#
#  id                                      :integer          not null, primary key
#  hide_thumbnails_before_start            :boolean
#  hide_feedback_before_finish             :boolean
#  hide_compilation_feedback_before_finish :boolean
#  no_review_before_close                  :boolean
#  hide_feedback_in_review_before_close    :boolean
#  hide_thumbnails_in_review_before_close  :boolean
#  no_hints                                :boolean
#  no_faq                                  :boolean
#  name                                    :string(255)
#  created_at                              :datetime
#  updated_at                              :datetime
#  invisible_before_review                 :boolean
#  description                             :string(255)
#

class WorkoutPolicy < ActiveRecord::Base
  has_many :workout_offerings, inverse_of: :workout_policy, dependent: :nullify
end
