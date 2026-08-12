class AddSeeAnswersToWorkoutPolicies < ActiveRecord::Migration[5.2]
  def change
    add_column :workout_policies, :see_answers, :boolean, default: true, null: false

    [
      :hide_thumbnails_before_start,
      :hide_feedback_before_finish,
      :hide_compilation_feedback_before_finish,
      :no_review_before_close,
      :hide_feedback_in_review_before_close,
      :hide_thumbnails_in_review_before_close,
      :no_hints,
      :no_faq,
      :invisible_before_review,
      :hide_score_before_finish,
      :hide_score_in_review_before_close
    ].each do |field|
      change_column_null :workout_policies, field, false, false
      change_column_default :workout_policies, field, from: nil, to: false
    end
  end
end
