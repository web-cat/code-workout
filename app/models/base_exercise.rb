# == Schema Information
#
# Table name: base_exercises
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  question_type      :integer
#  current_version    :integer
#  created_at         :datetime
#  updated_at         :datetime
#  versions           :integer
#  variation_group_id :integer
#

class BaseExercise < ActiveRecord::Base

  #~ Relationships ............................................................

  has_many :exercises
  belongs_to :validation_group


  #~ Hooks ....................................................................

  before_validation :set_defaults


  #~ Validation ...............................................................

  validates :current_version, presence: true, numericality: true

  Q_MC     = 1
  Q_CODING = 2
  Q_BLANKS = 3

  TYPE_NAMES = {
    Q_MC     => 'Multiple Choice Question',
    Q_CODING => 'Coding Question',
    Q_BLANKS => 'Fill in the blanks'
  }


  #~ Public instance methods ..................................................

  def type_name
    TYPES[self.question_type]
  end


  #~ Private instance methods .................................................
  private

  def set_defaults
    self.question_type ||= Q_MC
  end

end
