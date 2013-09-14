# == Schema Information
#
# Table name: course_offerings
#
#  id                      :integer          not null, primary key
#  course_id               :integer
#  term_id                 :integer
#  name                    :string(255)
#  label                   :string(255)
#  url                     :string(255)
#  self_enrollment_allowed :boolean
#  created_at              :datetime
#  updated_at              :datetime
#

class CourseOffering < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to  :course
  belongs_to  :term


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
