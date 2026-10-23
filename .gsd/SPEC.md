# Specifications

---

# 1. Multiple Workout Attempts Specification

## Status: FINALIZED

### 1.1 Overview
Currently, workouts in CodeWorkout can only be attempted once, with a single `WorkoutScore` record per `(user_id, workout_offering_id)`. For quizzes, timed practice assessments, and mastery learning, workouts need to support multiple attempts—similar to Canvas LMS quizzes—where each attempt corresponds to a distinct `WorkoutScore`.

This feature allows instructors to configure `workout_attempt_limit` (e.g. 1, 2, 3... or unlimited/nil) and `score_to_keep` (`highest` [default] or `latest`, stored as a boolean). Each attempt has its own independent countdown timer bounded by the offering's hard deadline. Gradebook displays and LMS grade passback via LTI use the kept/effective score. Instructors can also grant extra attempts to individual students via `StudentExtension`.

---

### 1.2 Functional Requirements

#### 1.2.1 Attempt Controls & Configuration
- **Workout Offering Attributes**:
  - `workout_attempt_limit` (`integer`, default: `1`, `nil` or `<= 0` represents unlimited). Note: distinct from existing `attempt_limit` which applies to individual exercise questions.
  - `score_to_keep` (`boolean`, default: `false`, `null: false`).
    - `false` = `highest` (Canvas default: keeps max score across attempts)
    - `true` = `latest` (keeps the score of the most recent attempt)
    - Mapped in ActiveRecord via `enum score_to_keep: { highest: false, latest: true }`.
- **Student Extension Overrides**:
  - `workout_attempt_limit` (`integer`, default: `nil`): If set, overrides the offering's `workout_attempt_limit` for the given student.
- **Deadlines YAML Configuration**:
  - In `WorkoutsController#create_or_update_offerings`, support configuring `workout_attempts` and `score_to_keep` in YAML:
    ```yaml
    sections:
      - section: CS 1114
        due: 2026-10-20 11:59 PM
        workout_attempts: 2
        score_to_keep: highest
    extensions:
      - students: [student@vt.edu]
        workout_attempts: 3
    ```
  - YAML round-trip serialization preserves these attributes.
- **Workout Edit Form UI**:
  - Add fields for "Allowed Workout Attempts" and "Score to Keep" (Highest vs Latest) in `app/views/workouts/_form.html.haml`.

#### 1.2.2 Attempt Lifecycle & Independent Timers
- **`WorkoutScore` Sequence Tracking**:
  - Each attempt gets its own `WorkoutScore` with `attempt_number` (`integer`, default: `1`, `null: false`).
  - Sequenced sequentially per `(user_id, workout_offering_id)`.
  - Fresh starter code / unanswered state for each new attempt.
- **Independent Timers**:
  - Each attempt has its own `started_at` timestamp.
  - The time limit countdown runs independently for each attempt (`started_at + time_limit`).
  - An attempt is closed when its time limit expires OR when the offering's `hard_deadline` passes (whichever comes first).
- **Concurrency Prevention**:
  - A student cannot start a new attempt if an active (unclosed) attempt is currently in progress (`can_start_new_attempt?` requires `active_score_for(user).nil?`).
  - Clicking "Start Workout" or "Take Workout Again" redirects to resume an existing open attempt.

#### 1.2.3 Access & Eligibility Rules (`WorkoutOffering`)
- `scores_for(user)`: Returns all `WorkoutScore`s for the user and offering, ordered by `attempt_number`.
- `active_score_for(user)`: Returns the currently unclosed `WorkoutScore` if one exists, else `nil`.
- `latest_score_for(user)`: Returns the most recent `WorkoutScore`.
- `attempts_allowed_for(user)`: Returns offering `workout_attempt_limit`, overridden by `StudentExtension#workout_attempt_limit` if present.
- `attempts_taken_for(user)`: Returns count of user's workout scores for this offering.
- `attempts_left_for(user)`: Calculates remaining attempts (`attempts_allowed - attempts_taken`). Returns `Float::INFINITY` if unlimited.
- `can_start_new_attempt?(user)`:
  - Enrolled student (or staff/admin).
  - Offering is published and within opening_date..hard_deadline.
  - `attempts_left_for(user) > 0`.
  - `active_score_for(user).nil?` (no concurrent unclosed attempt).
- `can_be_practiced_by?(user)`:
  - Must return `true` if an active attempt exists OR if `can_start_new_attempt?(user)` is true.
  - Does NOT lock the user out just because Attempt 1 is closed.
- `can_be_seen_by?(user)`:
  - Considers `active_score_for(user)` and attempt status; does not hide the workout if further attempts remain.

#### 1.2.4 Kept / Effective Score Calculation & LTI Grade Passback
- `effective_score_for(user)`:
  - When `score_to_keep == 'highest'` (default): `max(completed_attempt_scores)`.
  - When `score_to_keep == 'latest'`: score of the latest attempt.
- `kept_workout_score_for(user)`: Returns the `WorkoutScore` instance corresponding to the kept score.
- `score_for(user)`: Preserved for backward compatibility, returning `kept_workout_score_for(user)`.
- `WorkoutScore#update_lti`:
  - Posts `effective_score_for(user)` divided by total points to the LMS `lis_outcome_service_url`.
  - Prevents a lower second attempt from decreasing the grade in Canvas when policy is "Highest".

#### 1.2.5 Controller Actions & Attempt Binding
- **New Action `WorkoutOfferingsController#start_attempt`**:
  - POST endpoint to start a subsequent attempt.
  - Validates `can_start_new_attempt?(current_user)`.
  - Creates new `WorkoutScore` with `attempt_number: attempts_taken + 1`.
  - Redirects to first exercise of the workout.
- **`WorkoutOfferingsController#practice`**:
  - Resolves active attempt or creates Attempt 1 if none taken yet.
  - If past attempts exist and no active attempt, redirects to `show` with "Take Workout Again" option.
- **`ExercisesController#evaluate`**:
  - Binds new `Attempt` directly to `params[:workout_score_id]`.
  - Validates closed status against that specific `workout_score`.
- **`WorkoutOfferingsController#review` & `WorkoutsController#review`**:
  - Accepts optional `params[:workout_score_id]` or `params[:attempt_number]` to review past attempts.
  - Defaults to kept workout score.

#### 1.2.6 Views & UX
- `app/views/workouts/show.html.haml`:
  - Attempt summary header (Allowed, Taken, Score to Keep, Kept Grade).
  - Attempt history table with attempt numbers, dates, scores, and "Kept Score" badge.
  - Dynamic action button: "Resume Workout (Attempt X)" vs "Take Workout Again (Attempt X+1)" vs "Review Workout".
- `app/views/workouts/review.html.haml`:
  - Attempt selector (links/dropdown) to review individual attempts.
- `app/views/courses/_tab_grades.html.haml` & CSV Gradebook Exporters:
  - Display `effective_score_for(student)`.

### 1.3 Database Schema Changes
1. `workout_offerings`:
   - `workout_attempt_limit` (`integer`, default: `1`)
   - `score_to_keep` (`boolean`, default: `false`, `null: false`)
2. `student_extensions`:
   - `workout_attempt_limit` (`integer`, default: `nil`)
3. `workout_scores`:
   - `attempt_number` (`integer`, default: `1`, `null: false`)
   - Index `[:user_id, :workout_offering_id, :attempt_number]`

---

# 2. Error Table Deduplication & Aggregation Specification

## Status: FINALIZED

### 2.1 Overview
Refactor run-time error tracking in CodeWorkout to aggregate identical exceptions into a single row in the `errors` table using deterministic SHA-256 fingerprinting, an occurrence counter (`count`), and a timestamp (`last_seen_at`). This replaces the unbounded row-per-occurrence pattern that causes table bloat, alert fatigue, and triage difficulties, while enabling instant prioritization by error frequency in the ActiveAdmin dashboard.

---

### 2.2 Functional Requirements

#### 2.2.1 Schema Changes & Data Backfill
1. **New Columns on `errors` table**:
   - `fingerprint`: `varchar(64)`, indexed.
   - `count`: `integer`, `default: 1`, `null: false`, indexed.
   - `last_seen_at`: `datetime`.
2. **Safe Migration Backfill**:
   - For all existing rows in `errors`:
     - Compute the SHA-256 fingerprint from `class_name`, normalized `message`, and top 3 lines of `trace`.
     - Group existing records by fingerprint.
     - For each group with duplicate rows:
       - Retain the primary record (earliest created).
       - Update the primary record's `count` to the group size.
       - Update `last_seen_at` to the group's maximum `updated_at || created_at`.
       - Update latest context (`target`, `referrer`, `params`, `user_agent_id`) to the most recent occurrence.
       - Delete the duplicate records.
     - For unique records, set `count = 1`, `fingerprint = <computed>`, and `last_seen_at = updated_at || created_at`.
   - Migration is fully reversible (`down` method restores previous schema state).
   - Use Ruby's `Digest::SHA256` to prevent database-level collation mismatch issues.
   - Issue `OPTIMIZE TABLE errors` when running on MySQL/MariaDB to reclaim disk space.

#### 2.2.2 Model & Exception Handler Integration (`ExceptionHandler::Exception` and `Error`)
1. **User Agent Attribute Compatibility Fix**:
   - Resolve `ActiveModel::MissingAttributeError: can't write unknown attribute user_agent` in `ExceptionHandler::Exception`:
     - Associate `belongs_to :user_agent, optional: true`.
     - Add transparent virtual setter `def user_agent=(val)` matching `Error` model.
     - Update initialization attribute assignment from `self[type] = ...` to `send("#{type}=", ...)`.
2. **Deterministic Fingerprint Generator**:
   - Method `generate_fingerprint` in `ErrorAggregation` concern:
     - Strips dynamic hex memory addresses (`0x[0-9a-fA-F]+`) from `message`.
     - Truncates trace to the top 3 lines.
     - Returns `Digest::SHA256.hexdigest("#{class_name}:#{sanitized_msg}:#{top_trace}")`.
3. **Deduplication Callback (`before_save :aggregate_duplicate_errors`)**:
   - Populates `fingerprint ||= generate_fingerprint`.
   - Populates `last_seen_at ||= Time.current`.
   - Checks if an existing record with the same fingerprint exists in `errors`:
     - If an existing record exists (with `id != self.id`):
       - Updates existing record via a thread-isolated connection:
         - `count: existing.count + 1`
         - `last_seen_at: Time.current`
         - Updates latest request context: `target`, `referrer`, `params`, `user_agent_id`
       - Executes `throw :abort` to stop saving the new record, preventing duplicate insertion.
     - If no existing record exists:
       - Ensures `self.count ||= 1`.

#### 2.2.3 ActiveAdmin Dashboard Updates (`app/admin/error.rb`)
1. **Default Sort Order**:
   - Configured to `:count_desc` so the most frequent errors appear at the top.
2. **Index Columns**:
   - `:count` (sortable by `:count`).
   - `:class_name` (sortable).
   - `:message` (truncated with link to show page).
   - `Last URL` (`:target`).
   - `:last_seen_at` (sortable).
   - `First Seen` (`:created_at`, sortable).
3. **Show Page & Filters**:
   - Displays `count`, `fingerprint`, and `last_seen_at`.
   - Added filters for `class_name`, `count`, `last_seen_at`, and `created_at`.

---

# 3. Randomized Exercise Pools in Workouts Specification

## Status: FINALIZED

### 3.1 Overview & Vision
Workouts currently present a fixed, linear list of exercises defined via `exercise_workouts`. To improve assessment security, minimize collusion, and provide variety across practice and retake attempts, workouts need support for randomized exercise pools.

Each "slot" in a workout's exercise sequence can either be:
1. A single fixed exercise ($N=1, k=1$).
2. A pool of candidate exercises ($N > 1$) from which $k$ exercises ($1 \le k \le N$) are drawn at random for each student attempt.

Instructors select the specific candidate exercises (the $N$), choose how many are drawn ($k$, `select_count`), and assign uniform points per selected exercise (total slot points = $k \times \text{points}$). When a student starts an attempt, the system samples $k$ exercises and records them in a snapshot table (`workout_score_exercises`), ensuring that the student's assigned exercises, order, and points remain stable throughout that attempt. When retakes/multiple attempts are permitted, subsequent attempts independently sample fresh exercises from each pool, actively minimizing repeat exercises where possible.

---

### 3.2 Goals
1. **Unified Slot/Pool Data Model**: Replace the rigid 1-to-1 workout-exercise relationship with a unified `ExercisePool` model where each slot in a workout has `position`, `name`, `select_count` ($k$), and uniform `points` per selected exercise.
2. **Deterministic Attempt Snapshotting**: Persist the sampled exercise instances for each student attempt (`WorkoutScore`) via an explicit join table (`workout_score_exercises`), ensuring test grading, navigation, review, and analytics are stable and reproducible.
3. **Anti-Duplication Resampling on Retakes**: On subsequent attempts for the same workout offering, draw fresh candidate exercises from the pool that the student has not yet seen, falling back to least-frequently seen candidates only when pool size $N$ is exhausted.
4. **Intuitive Workout Authoring UI**: Allow instructors in the workout builder to configure both standard single-exercise slots and multi-exercise pools ($k$ from $N$) with drag-and-drop support, point specification, and ordering.
5. **Seamless Delivery & Review**: Update practice navigation (`next_exercise`), progress bars, grading feedback, and review interfaces to reflect the student's assigned attempt exercises, while giving instructors complete visibility into all candidate pool items in staff view.
6. **Backward Compatibility & Extensibility**: Ensure existing workouts and historical attempts are preserved and functional, and maintain a decoupled design ready for future question generator templates.

---

### 3.3 Non-Goals (Out of Scope for this Milestone)
- **Question Generators / Dynamic AST Parameterization**: Generating code prompts or assertions on the fly via sandboxed scripts (e.g. PrairieLearn server.py) is explicitly deferred to a future milestone.
- **Global Reusable Item Banks**: Creating a global, course-independent item bank manager is deferred; exercise pools are scoped directly to workouts as slots.
- **Cross-Slot Dependency Rules**: Advanced selection constraints (e.g., "if problem A is picked in Slot 1, do not pick problem B in Slot 2") are out of scope.

---

### 3.4 Functional Requirements

#### 3.4.1 Data Models & Relationships
1. **`ExercisePool`**:
   - `workout_id` (`bigint`, foreign key to `workouts`, not null)
   - `name` (`string`, optional label, e.g. "Loop Practice Pool")
   - `position` (`integer`, not null, managed via `acts_as_list scope: :workout`)
   - `select_count` (`integer`, default: `1`, not null, must be $\ge 1$)
   - `points` (`float`, default: `1.0`, not null, uniform points per selected exercise)
   - Associations:
     - `belongs_to :workout, inverse_of: :exercise_pools`
     - `has_many :exercise_pool_items, -> { order('position ASC') }, inverse_of: :exercise_pool, dependent: :destroy`
     - `has_many :exercises, through: :exercise_pool_items`
   - Validations:
     - `select_count` must be positive and $\le$ `exercises.count` (when saved/published).
     - `points` must be $\ge 0$.

2. **`ExercisePoolItem`**:
   - `exercise_pool_id` (`bigint`, foreign key to `exercise_pools`, not null)
   - `exercise_id` (`bigint`, foreign key to `exercises`, not null)
   - `position` (`integer`, default: `1`, order within the pool editor)
   - Validations:
     - Unique index on `[:exercise_pool_id, :exercise_id]`.

3. **`WorkoutScoreExercise`**:
   - `workout_score_id` (`bigint`, foreign key to `workout_scores`, not null)
   - `exercise_id` (`bigint`, foreign key to `exercises`, not null)
   - `exercise_pool_id` (`bigint`, foreign key to `exercise_pools`, not null)
   - `position` (`integer`, not null, 1-based order in student's attempt)
   - `points` (`float`, not null, points allocated for this exercise)
   - Associations:
     - `belongs_to :workout_score, inverse_of: :workout_score_exercises`
     - `belongs_to :exercise`
     - `belongs_to :exercise_pool`
   - Indexes:
     - Unique compound index on `[:workout_score_id, :exercise_id]`
     - Index on `[:workout_score_id, :position]`

4. **`Workout` Integration & Migration**:
   - `has_many :exercise_pools, -> { order('position ASC') }, inverse_of: :workout, dependent: :destroy`
   - `has_many :exercises, through: :exercise_pools`
   - `total_points`: Computed as $\sum (\text{pool.select\_count} \times \text{pool.points})$.
   - Migration backfills all existing `exercise_workouts` into 1-exercise `exercise_pools` ($k=1$) so existing workouts continue operating seamlessly.

#### 3.4.2 Attempt Instantiation & Anti-Duplication Sampling
1. **Instantiation Lifecycle**:
   - When a `WorkoutScore` is instantiated (e.g. `workout_offering.score_for`, `start_attempt`, or first visit to `practice`), `WorkoutScore#generate_attempt_exercises!` is invoked.
   - For each `exercise_pool` in `workout.exercise_pools`:
     - Finds all exercise IDs previously attempted by this user in prior `WorkoutScore`s for this workout/offering:
       `previously_seen_ids = user.workout_scores.joins(:workout_score_exercises).where(workout: workout).where.not(id: id).where('workout_score_exercises.exercise_pool_id = ?', pool.id).pluck('workout_score_exercises.exercise_id').uniq`.
     - Candidate IDs = `pool.exercise_pool_items.pluck(:exercise_id)`.
     - Fresh unseen candidate IDs = `candidate_ids - previously_seen_ids`.
     - If `fresh_unseen_ids.size >= pool.select_count`:
       - Sample `pool.select_count` randomly without replacement from `fresh_unseen_ids`.
     - Else:
       - Include all `fresh_unseen_ids`.
       - Fill the remaining quota from `previously_seen_ids` (randomized or ordered by least-recently seen).
     - Assign sequential 1-based `position` and copy `pool.points` to each `WorkoutScoreExercise`.
   - `workout_score.exercises_remaining` is initialized to the total count of assigned exercises, and `exercises_completed` is set to 0.

2. **Navigation & Practice Flow**:
   - `workout_score.exercises`: Returns the ordered collection of `Exercise`s assigned via `workout_score.workout_score_exercises.order(:position)`.
   - `workout.first_exercise(workout_score = nil)`: Returns the first assigned exercise for the given score (or first pool's first exercise if score is nil).
   - `workout.next_exercise(exercise, workout_score = nil)`: Traverses using `workout_score.workout_score_exercises` when a score is present.
   - `ExercisesController#practice` and `evaluate`:
     - Looks up maximum points for the current exercise from `workout_score.workout_score_exercises.find_by(exercise: @exercise)&.points`.
     - Ensures navigation buttons ("Next Exercise") route to the next assigned exercise in the attempt.

#### 3.4.3 Workout Authoring UI
1. **Workout Form (`app/views/workouts/_form.html.haml` & `workout_form.js.coffee`)**:
   - Allows adding single exercises (standard slots where $N=1, k=1$).
   - Allows grouping/creating an "Exercise Pool" slot:
     - Title/Name for the pool.
     - Number of exercises to select ($k$).
     - Points per exercise.
     - Drop target / list of candidate exercises ($N$).
   - Reordering of slots and exercises within pools via sortable drag-and-drop.
   - Validates that $k \le N$ for every pool before submission.
   - Form submission serializes pools and exercises as JSON payload to `workouts_controller.rb`.
2. **Workouts Controller Handling**:
   - `create` and `update` parse the pooled slot structure into `ExercisePool` and `ExercisePoolItem` records.

#### 3.4.4 Student & Staff Views
1. **Student Views**:
   - `workouts/show.html.haml`: If the student has an active/completed score, only their assigned exercises are displayed. If thumbnails are hidden before starting, displays standard placeholder.
   - `workouts/review.html.haml`: Displays only the exercises assigned to the selected attempt.
2. **Staff Views**:
   - In instructor/management view (`show.html.haml`), displays the workout's pool slots clearly labeled with candidate exercises and "Draw $k$ of $N$" indicators.
   - When reviewing a specific student's attempt (`review_user_id`), displays that student's specific assigned exercises.

