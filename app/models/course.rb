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
