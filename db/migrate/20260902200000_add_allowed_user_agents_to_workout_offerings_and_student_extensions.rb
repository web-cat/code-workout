class AddAllowedUserAgentsToWorkoutOfferingsAndStudentExtensions < ActiveRecord::Migration[5.2]
  def change
    add_column :workout_offerings, :allowed_user_agents, :text
    add_column :student_extensions, :allowed_user_agents, :text
    add_column :workout_scores, :last_user_agent, :text
    add_column :activity_logs, :user_agent, :text
  end
end
