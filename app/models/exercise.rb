# == Schema Information
#
# Table name: exercises
#
#  id                 :integer          not null, primary key
#  user_id            :integer          not null
#  stem_id            :integer
#  title              :string(255)
#  question           :text             not null
#  feedback           :text
#  is_public          :boolean          not null
#  priority           :integer          not null
#  count_attempts     :integer          not null
#  count_correct      :float            not null
#  difficulty         :float            not null
#  discrimination     :float            not null
#  question_type      :integer          not null
#  mcq_allow_multiple :boolean
#  mcq_is_scrambled   :boolean
#  created_at         :datetime
#  updated_at         :datetime
#  experience         :integer
#  starter_code       :text
#
# Indexes
#
#  index_exercises_on_stem_id  (stem_id)
#  index_exercises_on_user_id  (user_id)
#

#table/schema migration for exercise........................
#
#create_table "exercises", force: true do |t|
#    t.integer  "user_id",            null: false
#    t.integer  "stem_id"
#    t.integer  "language_id"
#    t.string   "title",              null: false
#    t.text     "question",           null: false
#    t.text     "feedback"
#    t.boolean  "is_public",          null: false
#    t.integer  "priority",           null: false
#    t.integer  "count_attempts",     null: false
#    t.float    "count_correct",      null: false
#    t.float    "difficulty",         null: false
#    t.float    "discrimination",     null: false
#    t.integer  "question_type",      null: false
#    t.boolean  "mcq_allow_multiple"
#    t.boolean  "mcq_is_scrambled"
#    t.datetime "created_at"
#    t.datetime "updated_at"
#    t.integer  "experience"
#  end

require "cgi"

class Exercise < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to  :user
  belongs_to  :stem
  #belongs_to  :language #language is now a tag with tagtype=2

  has_and_belongs_to_many :tags
  has_and_belongs_to_many :workouts
  has_many :choices
  has_many :attempts
  accepts_nested_attributes_for :attempts
  accepts_nested_attributes_for :choices, :allow_destroy => true
  accepts_nested_attributes_for :tags, :allow_destroy => true
  
  
  #~ Hooks ....................................................................
  before_validation :set_defaults
  #~ Validation ...............................................................

  #validates :user, presence: true
  validates :title,
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

  TEASER_LENGTH = 40

  #~ Class methods ............................................................
  def self.search(terms)
    term_array = terms.split
    term_array.each do |term|
      term = "%" + term + "%"
    end
    return Exercise.joins(:tags).where{tags.tag_name.like_any term_array}
  end

  def self.type_mc
    TYPES['Multiple Choice Question']
  end

  #~ Public instance methods ..................................................
  def serve_choice_array
    if self.choices.nil?
      return ["No answers available"]
    else
      answers = Array.new
      raw = self.choices.sort_by{|a| a[:order]}
      raw.each do |c|
        formatted = c
        formatted[:answer] = make_html(c[:answer])
        answers.push( formatted )
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

  def teaser_text
    plain = ActionController::Base.helpers.strip_tags(make_html(self.question))
    if( plain.size < TEASER_LENGTH )
      return plain
    else
      shorten = plain[0..TEASER_LENGTH]
      space = shorten.rindex(/\s/)
      if space.nil?
        shorten = shorten.to_s+"..."
      else
        shorten = shorten[0..space].to_s+"..."
      end
      return shorten
    end
  end

  def select_many?
    self.mcq_allow_multiple
  end

  def type_name
    Exercise.type_name(self.question_type)
  end

  def serve_question_html
    source = ""
    if stem
      source = stem.preamble
    end
    source = source + "<br>" + question
    return make_html(source)
  end

  def score(answered)
    score = 0
    answered.each do |a|
      score = score + a.value
    end
    if( score < 0 )
      score = 0
    end
    return score
  end

  
  #~Grab all feedback for choices either selected when wrong 
  #  or not selected when (at least partially) right
  def collate_feedback(answered)
    total = score(answered)
    feed = Array.new
    all = self.choices.sort_by{|a| a[:order]}
    all.each do |choice|
      found = answered.select {|x| x["id"] == choice.id}
      if( (choice.value > 0 && (found.nil? || found.empty?) ) ||
          ( choice.value <= 0 && (!found.nil? && !found.empty?) ) )
        feed.push( make_html(choice.feedback) )
      end
    end
    #if 100% correct, or no other feedback provided, give general feedback
    if( feed.empty? || total>= 100 && (!self.feedback.nil? && !self.feedback.empty?) )
      feed.push(self.feedback)
    end
    return feed
  end

  def experience_on(answered,attempt)
    total = score(answered)
    options = self.choices.size

    if( options == 0 || attempt == 0)
      return 0
    elsif( total >= 100 && attempt == 1 )
      return self.experience
    elsif( attempt >= options )
      return 0
    elsif( total >= 100 )
      return self.experience - self.experience * (attempt-1)/options
    else
      return self.experience / options / 4
    end
  end

  def make_html(unescaped)
    return CGI::unescapeHTML(unescaped.to_s).html_safe
  end

  #getter override for title
  def title
    temp = "X"+read_attribute(:id).to_s
    if not read_attribute(:title).nil? 
      temp += ": " + read_attribute(:title).to_s
    elsif( !self.tags.nil? && !self.tags.first.nil? )
      temp += ": " + self.tags.first.tag_name
    end
    return temp
  end

  private
  def self.type_name(type_num)
    if( type_num.nil? || type_num <= 0 || type_num > TYPES.size )
      return ""
    else
      return TYPES.rassoc(type_num).first
    end
  end

  def set_defaults
    self.user_id ||= 1
    self.title ||= " "
    self.is_public ||= true
    self.priority ||= 0
    self.count_attempts ||= 0
    self.count_correct ||= 0
    self.difficulty ||= 50
    self.experience ||= 100
    self.discrimination ||= 0
    self.question_type ||= TYPES['Multiple Choice Question']
  end
end
