# == Schema Information
#
# Table name: workouts
#
#  id                :integer          not null, primary key
#  name              :string(255)      not null
#  scrambled         :boolean          default(FALSE)
#  created_at        :datetime
#  updated_at        :datetime
#  description       :text
#  points_multiplier :integer
#  creator_id        :integer
#  external_id       :string(255)
#
# Indexes
#
#  index_workouts_on_external_id  (external_id) UNIQUE
#

# =============================================================================
# Represents a collection of exercises given as an assignment.  A workout
# can be associated with one or more courses through workout offerings,
# which represent individual assignments of the same workout in different
# courses or terms.
#
# In addition, each user who starts a workout is associated with the
# workout through one or more WorkoutScores--these WorkoutScore objects
# represent that user's score on the exercises in one completion of this
# workout.
#
# Note that workouts can implicitly be "owned" by courses.  Effectively,
# the "courses" associated with a workout are those for which course
# offerings have been given workout offerings.
#
class Workout < ActiveRecord::Base

  #~ Relationships ............................................................

  acts_as_taggable_on :tags, :languages, :styles
	has_many :exercise_workouts, -> { order("'position' ASC") },
	  inverse_of: :workout, dependent: :destroy
  has_many :exercises, through:  :exercise_workouts
	has_many :workout_scores, inverse_of: :workout, dependent: :destroy
  has_many :users, through: :workout_scores
  has_many :attempts
  has_many :workout_offerings, inverse_of: :workout, dependent: :destroy
  has_many :course_offerings, through:  :workout_offerings
  has_many :courses, through: :course_offerings
  belongs_to :creator, class_name: 'User'
  has_many :workout_owners, inverse_of: :workout, dependent: :destroy
  has_many :owners, through: :workout_owners

  accepts_nested_attributes_for :exercise_workouts
  accepts_nested_attributes_for :workout_offerings


  #~ Validation ...............................................................

	validates :name,
    presence: true,
    length: { minimum: 1 },
    format: {
      with: /[a-zA-Z0-9\-_: .]+/,
      message: 'The workout name must consist only of letters, digits, ' \
        'hyphens (-), underscores (_), spaces ( ), colons (:) ' \
        ' and periods (.).'
    }


  #~ Hooks ....................................................................

  # paginates_per 1


  #~ Class methods ............................................................

  # -------------------------------------------------------------
  def add_exercise(ex)
    self.exercise_workouts <<
      ExerciseWorkout.new(workout: self, exercise: ex)
  end


  # -------------------------------------------------------------
  # return the totals points of the exercises in the current workout.
  # FIXME: Why isn't this a property of the workout?  The exercises
  # themselves don't record absolute points at all!
  def returnTotalWorkoutPoints
    total_points = 0.0
    self.exercises.each do |ex|
      total_points += ExerciseWorkout.findExercisePoints(ex.id, self.id)
    end
    return total_points
  end
  
  # -------------------------------------------------------------
  # Simple method to return the number of exercises a workout has
  def num_exercises
    self.exercises.length
  end


  # -------------------------------------------------------------
  # returns a hash of exercise experience points (XP) with
  # { scored: ___, total: ___, percent: ___ }
  # FIXME: refactor to use workout score instead
  def xp(u_id)
    xp = Hash.new
    xp[:scored] = 0
    xp[:total] = 0
    exs = self.exercises
    exs.each do |x|
      x_attempt = x.attempts.where(user_id: u_id).pluck(:experience_earned)
      x_attempt.each do |a|
        xp[:scored] = xp[:scored] + a
      end
      xp[:total] = xp[:total] + x.experience
    end
    if  xp[:total] > 0
      xp[:percent] = xp[:scored].to_f / xp[:total].to_f * 100
    else
      xp[:percent] = 0
    end
    return xp
  end

  # ------------------------------------------------------------
  def next_exercise(ex,user)
    if user.nil?
      puts "Invalid USER"
    end   
        
    (1..self.num_exercises).each do |i|
      if ex
        exw = ExerciseWorkout.find_by(exercise: ex,workout: self)
        candiate_exercise_position = (exw.position+i)%self.num_exercises
        candiate_exercise_position = exw.position+i if candiate_exercise_position == 0
      else
        candiate_exercise_position = 1
      end
      puts "CANDIDATE POSITION",candiate_exercise_position,"CANDIDATE POSITION"
      candidate_exercise = ExerciseWorkout.
             find_by(position: candiate_exercise_position, workout: self).exercise
      candidate_attempt = Attempt.user_attempt(user, candidate_exercise.current_version)
      if candidate_attempt
        return candidate_exercise if candidate_attempt.score !=  
          ExerciseWorkout.find_by(position: candiate_exercise_position, workout: self).points
      else
        return candidate_exercise
      end      
    end
    # Reaching this point means none of the exercises (possibly apart from the current)
    # has scored a perfect score  
    return nil 
  end

  # -------------------------------------------------------------
  def all_tags
    coll = self.tags.pluck(:tag_name).uniq
    self.exercises.each do |x|
      x_tags = x.tags.pluck(:tag_name).uniq
      x_tags.each do |another|
        if coll.index(another).nil?
          coll.push(another)
        end
      end
    end
    return coll
  end


  # -------------------------------------------------------------
  def highest_difficulty
    diff = 0
    self.exercises.each do |x|
      x_diff = x.andand.irt_data.andand.difficulty || 0
      if x_diff > diff
        diff = x_diff
      end
    end
    return diff
  end


  # -------------------------------------------------------------
  # FIXME: refactor to use workout score instead
  def xp_distribution(u_id)
    results = self.xp(u_id)
    earned = results[:scored]
    earned_per = results[:percent]
    total = results[:total]
    remaining = 0
    self.exercises.each do |x|
      x_attempt = x.attempts.where(user_id: u_id).pluck(:experience_earned)
      x_earned = 0
      x_attempt.each do |a|
        x_earned += a
      end
      remaining += x.experience - x_earned
    end
    remaining_per = remaining / total.to_f * 100
    gap = total - earned - remaining
    gap_per = 100 - earned_per - remaining_per
    return [earned, remaining, gap, earned_per, remaining_per, gap_per]
  end


  #~ Class methods ............................................................

  # -------------------------------------------------------------
  def self.search(terms)
    return Workout.tagged_with(terms, wild: true, on: :tags) +
      Workout.tagged_with(terms, wild: true, on: :languages) +
      Workout.tagged_with(terms, wild: true, on: :styles)
  end

end
