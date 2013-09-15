class Tag < ActiveRecord::Base
  #~ Relationships ............................................................

  has_and_belongs_to_many :exercises


  #~ Hooks ....................................................................
  before_validation :set_name_case

  #~ Validation ...............................................................

  #validates :user, presence: true
  validates :name,
    presence: true,
    length: {:minimum => 1},
    format: {
      with: /[a-z0-9\-_]+/,
      message: 'title must consist only of letters, digits, hyphens (-), ' \
        'and underscores (_).'
    },
    uniqueness: true
  #~ Private instance methods .................................................
  private

  # -------------------------------------------------------------
  def set_name_case
    if !self.name.empty?
      self.name = name.downcase
    end
  end
end