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
  has_many :exercises_tags
  has_many :choices
  has_many :attempts
  accepts_nested_attributes_for :attempts
  accepts_nested_attributes_for :choices, :allow_destroy => true
  accepts_nested_attributes_for :tags, :allow_destroy => true
  
  
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
  def self.search(terms)
    term_array = terms.split
    term_array.each do |term|
      term = "%" + term + "%"
    end
    return Exercise.joins(:tags).where{tags.tag_name.like_any term_array}
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
    if( plain.size > 80 )
      return plain
    else
      return (plain[0..79])
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

#  def tag_with(tag_name, tag_type)
#    duplicate = self.tags.bsearch{|t| t.tag_name == tag_name}
#    if( duplicate.nil? )
#      #create temp tag to standardize tag name convention
#      temp = Tag.new
#      temp.tag_name = tag_name
#      temp.tagtype = tag_type
#      tagged = Tag.where(:tag_name => temp.tag_name, 
#        :tagtype => temp.tagtype).first_or_create
#      tagged.total_exercises = tagged.total_exercises + 1
#      tagged.total_experience += self.experience
#      tagged.save
#      self.tags << tagged
#      tagged.exercises << self
#    end
#  end

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



  private
  def self.type_name(type_num)
    if( type_num.nil? || type_num <= 0 || type_num > TYPES.size )
      return ""
    else
      return TYPES.rassoc(type_num).first
    end
  end
end