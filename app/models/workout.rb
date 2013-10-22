#~ Migration for workouts.........
# create_table "workouts", force: true do |t|
#    t.string   "name",                       null: false
#    t.boolean  "scrambled",  default: false
#    t.datetime "created_at"
#    t.datetime "updated_at"
#  end
#
#  create_table "workouts_exercises", force: true do |t|
#    t.integer  "workout_id",  null: false
#    t.integer  "exercise_id", null: false
#    t.integer  "points"
#    t.integer  "order"
#    t.datetime "created_at"
#    t.datetime "updated_at"
#  end
#
#  add_index "workouts_exercises", ["exercise_id"], name: "index_workouts_exercises_on_exercise_id"
#  add_index "workouts_exercises", ["workout_id"], name: "index_workouts_exercises_on_workout_id"


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

end
