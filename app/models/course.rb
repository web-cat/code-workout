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
#  creator_id      :integer
#
# Indexes
#
#  index_courses_on_organization_id  (organization_id)
#  index_courses_on_url_part         (url_part)
#

class Course < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to  :organization, inverse_of: :courses
  has_many    :course_offerings, inverse_of: :course, dependent: :destroy
  # Associating with exercises through course_exercises
  has_many    :exercises, through: :course_exercises
  has_many    :course_exercises, inverse_of: :course, dependent: :destroy

  #Kaminari for the show method
  paginates_per 100

  accepts_nested_attributes_for :course_offerings, allow_destroy: true


  #~ Validation ...............................................................

  validates :name, presence: true
  validates :number, presence: true
  validates :organization, presence: true
  validates :url_part,
    presence: true,
    format: {
      with: /[a-z0-9\-_.]+/,
      message: 'must consist only of letters, digits, hyphens (-), ' \
        'underscores (_), and periods (.).'
    },
    uniqueness: { case_sensitive: false }


  #~ Hooks ....................................................................

  before_validation :set_url_part


  #~ Class methods ............................................................

  # -------------------------------------------------------------
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


  # -------------------------------------------------------------
  def display_name
    number_and_name
  end


  # -------------------------------------------------------------
  def number_and_name
    "#{number}: #{name}"
  end


  # -------------------------------------------------------------
  def number_and_org
    "#{number} (#{organization.url_part})"
  end


  # -------------------------------------------------------------
  def number_and_organization
    "#{number} (#{organization.name})"
  end


  #~ Private instance methods .................................................
  private

  # -------------------------------------------------------------
  def set_url_part
    self.url_part = url_part_safe(number)
  end

end
