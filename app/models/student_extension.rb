# == Schema Information
#
# Table name: student_extensions
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  workout_offering_id :integer
#  soft_deadline       :datetime
#  hard_deadline       :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  time_limit          :integer
#  opening_date        :datetime
#
# Indexes
#
#  index_student_extensions_on_user_id              (user_id)
#  index_student_extensions_on_workout_offering_id  (workout_offering_id)
#

class StudentExtension < ActiveRecord::Base

  belongs_to :user
  belongs_to :workout_offering

  # Creates new or updates an existing StudentExtension.
  # Expects data in the format returned by the workout form.
  def self.create_or_update!(student, workout_offering, opts)
    student_extension = StudentExtension.find_by(user: student,
                                                 workout_offering: workout_offering)
    if student_extension.blank?
      student_extension = StudentExtension.new
    end
    student_extension.user = student
    student_extension.workout_offering = workout_offering

    # extension deadlines
    if opts['opening_date'].present?
      student_extension.opening_date =
        DateTime.strptime(opts['opening_date'].to_s, '%Q')
    end
    if opts['soft_deadline'].present?
      student_extension.soft_deadline =
        DateTime.strptime(opts['soft_deadline'].to_s, '%Q')
    end
    if opts['hard_deadline']
      student_extension.hard_deadline =
        DateTime.strptime(opts['hard_deadline'].to_s, '%Q')
    end
    student_extension.time_limit = opts['time_limit'] if opts['time_limit'].present?
    student_extension.save!
  end
end
