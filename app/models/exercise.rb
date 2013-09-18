#table/schema migration for exercise........................
#
# create_table :exercises do |t|
#      t.belongs_to  :user, index: true, null: false
#      t.belongs_to  :stem, index: true
#      t.belongs_to  :language, index: true
#      t.has_and_belongs_to_many :tags
#
#      t.string    :title, null: false
#      t.text    :question, null: false
#      t.text    :feedback
#      t.boolean   :is_public, null: false
#      t.integer   :prioriy, null: false
#      t.integer   :count_attempts, null: false
#      t.float   :count_correct, null: false
#      t.float   :difficulty, null: false
#      t.float   :discrimination, null: false
#      t.integer   :type, null: false
#
#      #MCQ-specific columns, using single-table inheritance:
#      t.boolean   :mcq_allow_multiple
#      t.boolean   :mcq_is_scrambled
#
#      t.timestamps

class Exercise < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to  :user
  belongs_to  :stem
  belongs_to  :language
  #has_many :tags, :through => :exercises_tags
  has_and_belongs_to_many :tags
  has_many :exercises_tags
  
  
  #~ Hooks ....................................................................

  #~ Validation ...............................................................

  #validates :user, presence: true
  validates :title,
    presence: true,
    length: {:minimum => 1, :maximum => 80},
    format: {
      with: /[a-zA-Z0-9\-_ .]+/,
      message: 'Title must be 80 characters or less and consist only of ' \
        'letters, digits, hyphens (-), underscores (_), spaces ( ), and ' \
        'periods (.).'
    }
  validates :question, presence: true
  validates :is_public, presence: true
  validates :priority, presence: true, numericality: true
  validates :count_attempts, presence: true, numericality: true
  validates :count_correct, presence: true, numericality: true
  validates :difficulty, presence: true, numericality: true
  validates :discrimination, presence: true, numericality: true
  validates :type, presence: true, numericality: true


  TYPES = {
    'Multiple Choice Question' => 1
  }

  #~ Class methods ............................................................
  def self.type_name(type_num)
    TYPES.rassoc(type_num).first
  end

  #~ Private instance methods .................................................
  private

  def get_stem

  end

end
