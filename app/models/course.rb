# == Schema Information
#
# Table name: courses
#
#  id              :integer          not null, primary key
#  name            :string(255)      not null
#  number          :string(255)      not null
#  organization_id :integer          not null
#  url_part        :string(255)      not null
#  created_at      :datetime
#  updated_at      :datetime
#
# Indexes
#
#  index_courses_on_organization_id  (organization_id)
#  index_courses_on_url_part         (url_part) UNIQUE
#

class Course < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to  :organization
  has_many    :course_offerings
  # Associating with exercises through course_exercises
  has_many    :exercises, through: :course_exercises
  has_many    :course_exercises
  
  #Kaminari for the show method
  paginates_per 2
  
  accepts_nested_attributes_for :course_offerings, :allow_destroy => true
  
  #~ Hooks ....................................................................

  before_validation :set_url_part
  

  #~ Validation ...............................................................

  validates :name, presence: true
  validates :number, presence: true
  validates :organization, presence: true
  validates :url_part,
    presence: true,
    uniqueness: { case_sensitive: false }


  #~ Private instance methods .................................................

  private

  # -------------------------------------------------------------
  def set_url_part
    self.url_part = url_part_safe(number)
  end

end
