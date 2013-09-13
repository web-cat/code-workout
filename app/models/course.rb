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
