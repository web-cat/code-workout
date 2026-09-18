class AddAllowedIpsToWorkoutOfferingsAndStudentExtensions < ActiveRecord::Migration[5.2]
  def change
    add_column :workout_offerings, :allowed_ips, :text
    add_column :student_extensions, :allowed_ips, :text
    add_column :workout_scores, :last_ip_address, :string
  end
end
