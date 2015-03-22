# == Schema Information
#
# Table name: courses
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  number          :string(255)
#  organization_id :integer
#  url_part        :string(255)
#  created_at      :datetime
#  updated_at      :datetime
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
  
  #~ Class methods
  def self.search(terms)
    resultant = []
    term_array = terms.split
    term_array.each do |term|
      term = "%" + term + "%"
      Course.where("name LIKE ?",term).find_each do |course|
        resultant<<course.id
      end
    end    
     
    return resultant 
  end

  private

  # -------------------------------------------------------------
  def set_url_part
    self.url_part = url_part_safe(number)
  end

end
