# Multiple Workout Attempts Roadmap

## Wave 1: Database Migration & Schema
- [x] Create migration adding `workout_attempt_limit` and `score_to_keep` to `workout_offerings`, `workout_attempt_limit` to `student_extensions`, and `attempt_number` to `workout_scores` with compound index
- [x] Run migration using `rvm 2.7.0 do bundle exec rake db:migrate`
- [x] Verify `db/schema.rb` and existing record defaults

## Wave 2: Models & Core Logic
- [x] Add `score_to_keep` enum and multi-attempt helper methods to `WorkoutOffering` (`scores_for`, `active_score_for`, `latest_score_for`, `attempts_allowed_for`, `attempts_taken_for`, `attempts_left_for`, `can_start_new_attempt?`, `effective_score_for`, `kept_workout_score_for`)
- [x] Refactor `WorkoutOffering#can_be_practiced_by?` and `can_be_seen_by?` to allow multiple attempts
- [x] Update `WorkoutScore`: auto-populate `attempt_number` and update `update_lti` to post `effective_score_for`
- [x] Update `StudentExtension` to support `workout_attempt_limit`
- [x] Write unit specs in `spec/models/workout_offering_spec.rb` and `spec/models/workout_score_spec.rb`

## Wave 3: Routing, Deadlines YAML & Controllers
- [x] Add `post :start_attempt` route for `workout_offerings` (both standalone and org-scoped)
- [x] Update `WorkoutsController#create_or_update_offerings` and `serialize_workout_offerings_to_yaml` to parse and serialize `workout_attempts` and `score_to_keep`
- [x] Implement `WorkoutOfferingsController#start_attempt`
- [x] Refactor `WorkoutOfferingsController#practice`, `show`, and `review` to support multiple attempts and attempt selection
- [x] Fix `ExercisesController#practice` and `evaluate` to accept and bind to `params[:workout_score_id]` instead of defaulting to Attempt 1
- [x] Write controller specs for multi-attempt actions

## Wave 4: Views & User Interface
- [x] Update `app/views/workouts/show.html.haml` with attempt summary, attempt history table, kept score indicator, and "Resume" / "Take Workout Again" buttons
- [x] Update `app/views/workouts/review.html.haml` with attempt selector tabs/dropdown
- [x] Update `app/views/exercises/practice.html.haml` with attempt counter and hidden `workout_score_id` binding
- [x] Update `app/views/courses/_tab_grades.html.haml` to display effective score and attempt count
- [x] Update gradebook CSV exporters (`course_offerings` and `courses`) to use `effective_score_for`
- [x] Update `app/views/workouts/_form.html.haml` to include workout attempt limit and score to keep inputs

## Wave 5: End-to-End Verification & Documentation
- [x] Run full test suite for models, controllers, and views
- [x] Create walkthrough artifact documenting changes and empirical test results
- [x] Update `.gsd/STATE.md` with final summary
