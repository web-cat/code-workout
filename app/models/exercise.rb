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
#      t.integer   :priority, null: false
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
  has_many :choices
  accepts_nested_attributes_for :choices
  
  
  #~ Hooks ....................................................................

  #~ Validation ...............................................................

  #validates :user, presence: true
  validates :title,
    presence: true,
    length: {:minimum => 1, :maximum => 50},
    format: {
      with: /[a-zA-Z0-9\-_ .]+/,
      message: 'Title must be 50 characters or less and consist only of ' \
        'letters, digits, hyphens (-), underscores (_), spaces ( ), and ' \
        'periods (.).'
    }
  validates :question, presence: true
  validates :is_public, presence: true
  validates :priority, presence: true, numericality: true
  validates :count_attempts, presence: true, numericality: true
  validates :count_correct, presence: true, numericality: true
  validates :experience, presence: true, numericality: true
  validates :difficulty, presence: true, numericality: true
  validates :discrimination, presence: true, numericality: true
  validates :question_type, presence: true, numericality: true


  TYPES = {
    'Multiple Choice Question' => 1
  }

  #~ Class methods ............................................................
  

  #~ Public instance methods ..................................................
  def serve_choice_array
    if self.choices.nil?
      return ["No answers available"]
    else
      answers = Array.new
      raw = self.choices.sort_by{|a| a[:order]}
      raw.each do |c|
        answers.push( c )
      end
      if self.mcq_is_scrambled
        scrambled = Array.new
        until answers.empty?
          rand = Random.rand(answers.length)
          scrambled.push(answers.delete_at(rand))
        end
        answers = scrambled
      end
      return answers
    end
  end

  def select_many?
    self.mcq_allow_multiple
  end

  def type_name
    Exercise.type_name(self.question_type)
  end

  def serve_question_stem
    if self.stem.nil?
      return ""
    else
      return self.stem.preamble
    end
  end

  def score(answered)
    score = 0
    answered.each do |a|
      score = score + a.value
    end
    #answered.each do |a|
    #  if !self.choices.nil? && !self.choices.where(:answer => a).empty?
    #    score = score + self.choices.where(:answer => a).first.value
    #  end
    return score
  end

  def collate_feedback(answered)
    feed = Array.new
    if( !self.feedback.nil? && !self.feedback.empty? )
      feed.push(self.feedback)
    end
    answered.each do |a|
      if !a.feedback.nil? && !a.feedback.empty?
        feed.push(a.feedback)
      end
    end
    return feed
  end

  private
  def self.type_name(type_num)
    TYPES.rassoc(type_num).first
  end
end
