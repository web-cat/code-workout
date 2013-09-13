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
