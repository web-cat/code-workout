# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

class Tag < ActiveRecord::Base
  #~ Relationships ............................................................

  has_and_belongs_to_many :exercises
  has_many :tag_user_scores

  #~ Hooks ....................................................................
  before_validation :standardize_tag, :standardize_tagtype

  #~ Validation ...............................................................
  validates :name,
    presence: true,
    length: {:minimum => 1},
    uniqueness: true

  TYPES = {
    'Misc' => 0,
    'Area' => 1,
    'Language' => 2,
    'Skill' => 3
  }

  #~ Public methods ...........................................................


  #~ Public class methods .....................................................
  def self.type_name(type)
    TYPES.rassoc(type).first
  end

  def self.misc
    return TYPES["Misc"]
  end

  def self.area
    return TYPES["Area"]
  end

  def self.language
    return TYPES["Language"]
  end

  def self.Skill
    return TYPES["Skill"]
  end

  #~ Private instance methods .................................................
  private
  def standardize_tag
    if( !self.name.nil? )
      #remove pre-/post- and replace in-whitespace make lower-case only 
      self.name = self.name.strip.gsub(/[\s]/,"_").downcase
    end
  end

  def standardize_tagtype
    if( self.tagtype.nil? || self.tagtype >= TYPES.length || self.tagtype < 0)
      self.tagtype = 0
    end
  end
end
