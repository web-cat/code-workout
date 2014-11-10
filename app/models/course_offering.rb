# == Schema Information
#
# Table name: course_offerings
#
#  id                      :integer          not null, primary key
#  course_id               :integer          not null
#  term_id                 :integer          not null
#  name                    :string(255)      not null
#  label                   :string(255)
#  url                     :string(255)
#  self_enrollment_allowed :boolean
#  created_at              :datetime
#  updated_at              :datetime
#
# Indexes
#
#  index_course_offerings_on_course_id  (course_id)
#  index_course_offerings_on_term_id    (term_id)
#

class CourseOffering < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to  :course
  belongs_to  :term
  accepts_nested_attributes_for :term
  has_many :workouts, through: :workout_offerings
  has_many :workout_offerings
  #~ Validation ...............................................................

  validates :name, presence: true
  validates :course, presence: true
  validates :term, presence: true
  


  #~ Public instance methods ..................................................

  # -------------------------------------------------------------
  def display_name
    if label.blank?
      name
    else
      "#{name} (#{label})"
    end
  end

end
