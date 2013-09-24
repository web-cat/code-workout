# == Schema Information
#
# Table name: exercises
#
#  id         :integer          not null, primary key
#  title      :string(255)      not null
#  preamble   :text
#  user       :integer          not null
#  is_public  :boolean          not null
#  created_at :datetime
#  updated_at :datetime
#

class Exercise < ActiveRecord::Base

  #~ Relationships ............................................................

  #TODO define user model and relate to exercises as authors
  #has_one  :user
  has_many :prompts
  has_and_belongs_to_many :tags


  #~ Hooks ....................................................................

  #~ Validation ...............................................................

  #validates :user, presence: true
  validates :title,
    presence: true,
    length: {:minimum => 1, :maximum => 80},
    format: {
      with: /[a-z0-9\-_ .]+/,
      message: 'title must consist only of letters, digits, hyphens (-), ' \
        'underscores (_), spaces ( ), and periods (.).'
    }
  #no validation for (optional) preamble
  validates :is_public, presence: true

  #~ Private instance methods .................................................
end
