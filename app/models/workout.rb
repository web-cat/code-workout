class Workout < ActiveRecord::Base
	has_and_belongs_to_many :exercises
	has_and_belongs_to_many :tags

	validates :name,
    presence: true,
    length: {:minimum => 1, :maximum => 50},
    format: {
      with: /[a-zA-Z0-9\-_: .]+/,
      message: 'Workout name must be 50 characters or less and consist only of ' \
        'letters, digits, hyphens (-), underscores (_), spaces ( ), colons (:) ' \
        ' and periods (.).'
    }


  def add_exercise(ex_id)
    duplicate = self.exercises.bsearch{|x| x.id == ex_id}
    if( duplicate.nil? )
      exists = Exercise.find(ex_id)
      if( !exists.nil? )
        self.exercises << exists
        exists.workouts << self
        self.order = self.exercises.size
      end
    end
  end

  # returns a hash of exercise experience points (XP) with {:scored => ___, :total => ___, :percent => ____}
  def xp(u_id)
    xp = Hash.new
    xp[:scored] = 0
    xp[:total] = 0
    exs = self.exercises
    exs.each do |x|
      x_attempt = x.attempts.where(:user_id => u_id).pluck(:experience_earned)
      x_attempt.each do |a|
        xp[:scored] = xp[:scored] + a
      end
      xp[:total] = xp[:total] + x.experience
    end
    xp[:total] > 0 ? xp[:percent] = xp[:scored].to_f/xp[:total].to_f*100 : xp[:percent] = 0
    return xp
  end

  def all_tags
    coll = self.tags.pluck(:tag_name).uniq
    exs = self.exercises
    exs.each do |x|
      x_tags = x.tags.pluck(:tag_name).uniq
      x_tags.each do |another|
        if( coll.index(another).nil? )
          coll.push(another)
        end
      end
    end
    return coll
  end

  def highest_difficulty
    diff = 0
    exs = self.exercises
    exs.each do |x|
      if( !x.difficulty.nil? && x.difficulty > diff )
        diff = x.difficulty
      end
    end
    return diff
  end

end
