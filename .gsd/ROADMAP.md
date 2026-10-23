# Roadmaps

---

# 1. Multiple Workout Attempts Roadmap

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

---

# 2. Error Table Deduplication & Aggregation Roadmap

## Wave 1: Database Migration & Backfill
- [x] Create migration `db/migrate/20261017120000_add_fingerprint_and_count_to_errors.rb`
  - Add `fingerprint` (`varchar(64)` indexed)
  - Add `count` (`integer, default: 1, null: false` indexed)
  - Add `last_seen_at` (`datetime`)
  - Backfill existing rows with Ruby SHA-256 fingerprinting and group deduplication
  - Support reversible rollback in `down`
- [x] Run migration using `rvm 2.7.0 do bundle exec rake db:migrate`
- [x] Verify `schema.rb` and test rollback/re-migration

## Wave 2: Model Deduplication & Bugfix
- [x] Fix `ActiveModel::MissingAttributeError: can't write unknown attribute user_agent` in `ExceptionHandler::Exception`
  - Associate `belongs_to :user_agent, optional: true`
  - Add virtual setter `user_agent=` matching `Error`
  - Update initialization attribute assignment from `self[type]=` to `send("#{type}=", ...)`
- [x] Implement deterministic `generate_fingerprint` in `ExceptionHandler::Exception` and `Error` via `ErrorAggregation` concern
- [x] Implement `aggregate_duplicate_errors` before-save callback
  - Find existing record by fingerprint
  - Update count, last_seen_at, and latest context attributes via thread-isolated connection
  - Abort insert via `throw :abort` when duplicate exists
- [x] Ensure `Error` model includes matching associations, attributes, and fingerprint helper via `ErrorAggregation` concern

## Wave 3: ActiveAdmin Dashboard Updates
- [x] Update `app/admin/error.rb`
  - Set default sort order to `:count_desc`
  - Configure index table columns: `:count`, `:class_name`, `:message`, `:target` ("Last URL"), `:last_seen_at`, `:created_at`
  - Enhance show page to display `:count`, `:fingerprint`, and `:last_seen_at`
  - Configure sidebar filters for `:count`, `:class_name`, `:last_seen_at`, `:created_at`

## Wave 4: Automated Testing & Spec Coverage
- [x] Verify existing test suite: run `rvm 2.7.0 do bundle exec rspec spec/models/exception_handler_spec.rb` to confirm all 19 specs pass
- [x] Add unit tests for fingerprinting and aggregation in `spec/models/exception_handler_spec.rb` and `spec/models/error_spec.rb`:
  - Test fingerprint generation normalizes dynamic memory addresses
  - Test initial error creation sets `count = 1`, `last_seen_at`, and `fingerprint`
  - Test duplicate error does not insert a new row, increments `count`, and updates `last_seen_at`
  - Test user agent association transparent resolution
- [x] Verify ActiveAdmin loading and routes

## Wave 5: End-to-End Verification & Documentation
- [x] Run full test suites (61 examples, 0 failures across error and user-agent models and controllers)
- [x] Test exception handling in Rails environment
- [x] Update `.gsd/STATE.md` with execution summary and verification evidence
- [x] Create walkthrough artifact documenting changes

---

# 3. Randomized Exercise Pools in Workouts Roadmap

## Wave 1: Database Schema & Migrations
- [x] Create type-agnostic migration for `exercise_pools` (`workout_id`, `name`, `position`, `select_count`, `points`, timestamps)
- [x] Create type-agnostic migration for `exercise_pool_items` (`exercise_pool_id`, `exercise_id`, `position`, timestamps)
- [x] Create type-agnostic migration for `workout_score_exercises` (`workout_score_id`, `exercise_id`, `exercise_pool_id`, `position`, `points`, timestamps)
- [x] Add backfill logic to seamlessly migrate existing `exercise_workouts` into 1-item `exercise_pools` ($k=1$)
- [x] Run migration using `rvm 2.7.0 do bundle exec rake db:migrate` and verify `db/schema.rb`

## Wave 2: Models, Associations & Sampling Logic
- [x] Implement `ExercisePool` model with `acts_as_list scope: :workout`, validations, and associations
- [x] Implement `ExercisePoolItem` join model with uniqueness validation
- [x] Implement `WorkoutScoreExercise` snapshot model with validations and associations
- [x] Update `Workout` model: `has_many :exercise_pools`, `has_many :exercises, through: :exercise_pools`, `total_points`, `first_exercise(score)`, and `next_exercise(ex, score)`
- [x] Implement `WorkoutScore#generate_attempt_exercises!` with anti-duplication sampling algorithm prioritizing unseen candidate exercises across multiple attempts
- [x] Write unit specs in `spec/models/exercise_pool_spec.rb`, `spec/models/workout_score_exercise_spec.rb`, and update `spec/models/workout_score_spec.rb`

## Wave 3: Practice Flow & Controllers Integration
- [x] Update `WorkoutOfferingsController#practice` and `WorkoutsController#practice` to initialize and snapshot attempt exercises on `WorkoutScore` creation
- [x] Update `ExercisesController#practice` and `evaluate` to read `@max_points` from `workout_score.workout_score_exercises` and navigate sequentially through attempt exercises
- [x] Update `WorkoutScore#rescore` and completion hooks to accurately reflect the attempt-specific exercise count and score
- [x] Write controller specs verifying end-to-end attempt generation, sequential navigation, and grading isolation

## Wave 4: Authoring UI & Workout Form Updates
- [x] Update `WorkoutsController#create` and `Workout#update_or_create` to accept and persist slot/pool definitions
- [x] Update `app/views/workouts/_form.html.haml` and `workout_form.js.coffee` to support creating pool slots, configuring $k$, setting uniform points, and dragging candidate exercises
- [x] Update `app/views/workouts/show.html.haml` to display pool groupings in staff view and assigned exercises in student view
- [x] Update `app/views/workouts/review.html.haml` to render student attempt snapshots
- [x] Write request/controller specs for workout creation and editing with exercise pools

## Wave 5: End-to-End Verification & Documentation
- [x] Run full test suite (`rvm 2.7.0 do bundle exec rspec`)
- [x] Verify edge cases (single exercise slots, retakes with $k \le N$, pool exhaustion, grading passback)
- [x] Update `.gsd/STATE.md` with execution summary and verification evidence
- [x] Create walkthrough artifact documenting changes

