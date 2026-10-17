# Multiple Attempts for Workouts: Design & Specification

## 1. Executive Summary

In CodeWorkout, a student attempting a `WorkoutOffering` (or a gym `Workout`) produces a `WorkoutScore` record that tracks their progress, timer, exercise attempts, and aggregate points. Currently, the entire application assumes a **1-to-1 relationship** between a user and a workout score for a given offering. Once a student starts a workout, their single score record is created; once their time limit expires or the deadline passes, the workout score is marked closed, permanently locking the student out of further attempts.

In real-world educational scenarios—especially for quizzes, timed practice assessments, or mastery learning—instructors frequently want to allow **multiple attempts**, matching the functionality found in Learning Management Systems like Canvas LMS.

This document:
1. **Identifies all locations across the codebase** where the single `WorkoutScore` assumption is embedded.
2. **Designs a robust, Canvas-compatible multiple-attempt architecture** for CodeWorkout.
3. **Specifies the exact list of changes** required across database schemas, models, controllers, views, background workers, and LTI grade passback.

---

## 2. Inventory of Existing Single-Attempt Assumptions in Code

The assumption that `WorkoutScore` is unique per `(user_id, workout_offering_id)` or `(user_id, workout_id)` permeates database schema, domain models, controllers, view partials, and reports.

### 2.1 Database Schema & Table Structure

1. **`workout_scores` Table** (`db/schema.rb:743-767`):
   - **Index**: `idx_ws_on_user_workout_workout_offering` on `(user_id, workout_id, workout_offering_id)`. While not configured with a SQL `UNIQUE` constraint, the index layout and application queries treat this tuple as an operational singleton.
   - **Missing Attempt Identifier**: There is no `attempt_number` or sequence index on `workout_scores` to distinguish Attempt 1 from Attempt 2.
   - **Missing State Tracking**: `completed` is a boolean flag, but there is no explicit attempt status (e.g., `in_progress`, `submitted`, `closed`, `abandoned`).

2. **`workout_offerings` Table** (`db/schema.rb:687-717`):
   - **Existing `attempt_limit` Column**: Column `attempt_limit` was originally added in migration `20190131151757_add_attempt_limit_to_workout_offerings.rb`. However, in code (`WorkoutScore#attempts_left_for_exercise_version`), it is used exclusively as an **exercise-level submission limit** (how many times a student may submit code for an individual question within the workout), *not* as a workout-level attempt limit.
   - **Missing Workout Attempt Controls**: There are no columns for `workout_attempt_limit` (number of times the whole workout may be retaken) or `score_to_keep` (scoring policy: `highest` vs. `latest`, representable as a boolean).

3. **`student_extensions` Table** (`db/schema.rb:510-523`):
   - Stores student-specific overrides for `soft_deadline`, `hard_deadline`, `opening_date`, `time_limit`, `allowed_ips`, and `allowed_user_agents`.
   - **Missing Attempt Accommodation**: Lacks an override for workout attempt count (e.g., allowing an instructor to grant an extra attempt to a student whose browser crashed).

---

### 2.2 Model Assumptions

#### A. `WorkoutOffering` (`app/models/workout_offering.rb`)
- **`score_for(user)`** (lines 88–101):
  ```ruby
  def score_for(user)
    if user.nil?
      return nil
    else
      if workout_scores.loaded?
        workout_scores.find { |ws| ws.user_id == user.id && ws.workout_id == workout_id }
      else
        workout_scores.where(user: user, workout: workout).order('updated_at DESC').first
      end
    end
  end
  ```
  *Assumption*: Assumes only one `WorkoutScore` exists per user, or arbitrarily returns `.first`. In-memory returns the first record found, while SQL returns the most recently updated record, creating subtle state divergences.
- **`can_be_practiced_by?(user)`** (lines 317–330):
  ```ruby
  workout_score = workout_scores.loaded? ? ... : workout_scores.where(user: user).last
  return false if workout_score && workout_score.closed?
  ```
  *Assumption*: If the user's latest workout score is closed (e.g., Attempt 1 timed out), the method immediately returns `false`. This completely blocks the student from ever starting Attempt 2.
- **`can_be_seen_by?(user)`** (lines 263–276):
  ```ruby
  uscore = score_for(user)
  ...
  (uscore == nil || !uscore.closed? || !workout_policy.andand.no_review_before_close || (hard_deadline && now >= hard_deadline))
  ```
  *Assumption*: Evaluates visibility against the single `uscore`. If Attempt 1 is closed and `no_review_before_close` is set, the student cannot even see the workout card or access the offering.
- **`ip_allowed?` and `user_agent_allowed?`** (lines 167–233):
  Both methods retrieve `ws = workout_score || (user ? score_for(user) : nil)` and cache the authorized client IP and User-Agent on that single `WorkoutScore`.

#### B. `Workout` (`app/models/workout.rb`)
- **Class Documentation** (lines 34–35, 70–83 of `WorkoutScore`): Explicitly states that while a user can repeat a workout across different offerings or in the gym, *"one user may have only one WorkoutScore for a given workout offering"*.
- **`score_for(user, workout_offering, ...)`** (lines 489–516):
  Uses `.first` or `.detect` against `workout_scores` matching the offering and LTI sourcedid. If a student launches via LTI for a second attempt, Canvas provides the same `lis_result_sourcedid`, causing `Workout#score_for` to return Attempt 1.
- **`add_workout_offerings`** (lines 410–473):
  Propagates `common[:attempt_limit]` into `workout_offering.attempt_limit` without distinguishing workout attempts from exercise attempts.

#### C. `WorkoutScore` (`app/models/workout_score.rb`)
- **`closed?`** (lines 126–140):
  Determines whether the score is closed based on `started_at` + `time_limit`. If a user only has one score object, once `closed?` becomes true, the user is permanently closed out.
- **`update_lti`** (lines 522–546):
  Pushes `self.score / total_points` directly to the LMS outcome URL. If a student scores 90 on Attempt 1 and 70 on Attempt 2, Attempt 2 will blindly overwrite the LMS gradebook with 70, even if the course policy is "Keep Highest".
- **`late` Scope** (lines 430–436):
  Inner joins `student_extensions` to find late scores, assuming 1 extension and 1 score per student.

#### D. `User` (`app/models/user.rb`)
- **`migrate_workout_scores_and_extensions`** (lines 847–861):
  Checks `sister_ws = sister_wo.score_for(self)`. If `sister_ws` exists, it logs `"Cannot migrate workout score... because of duplicate workout score"` and aborts.
- **`merge` / Deduplication** (lines 589–601, 758–770):
  Searches `self.workout_scores.where(workout: s.workout, workout_offering: s.workout_offering).limit(1).first` under the assumption of 1 score per offering.

---

### 2.3 Controller Assumptions

#### A. `WorkoutOfferingsController` (`app/controllers/workout_offerings_controller.rb`)
- **`practice` Action** (lines 160–276):
  - Line 161, 234, 251: Calls `@workout_score = @workout_offering.score_for(current_user)`.
  - Line 252: Only initializes a new `WorkoutScore` if `@workout_score.nil?`.
  - Line 265–276: If `@workout_score.closed?`, redirects out with `"The time limit has passed for this workout."`
  - *Result*: A student who completed Attempt 1 can never start Attempt 2; there is no logic to check if additional attempts remain or to create a subsequent `WorkoutScore`.
- **`show` Action** (lines 20–96):
  - Line 36: `@workout_score = @workout_offering.score_for(current_user)`.
  - Line 74: Fetches scoring attempts solely for that single score.
- **`review` Action** (lines 100–124):
  - Line 117: `@workout_score = @workout_offering.score_for(review_user)`.
  - Does not accept a `workout_score_id` or `attempt_number` parameter; impossible for student or instructor to view past attempts.

#### B. `ExercisesController` (`app/controllers/exercises_controller.rb`)
- **`practice` Action** (lines 666–680, 750–776):
  - Line 667–678: Falls back to `@workout_offering.score_for(@student_user)`.
  - Line 760–776: If `@workout_score.closed?`, redirects to workout offering view with notice.
  - Line 815–818: Loads attempts for the exercise from `@workout_score`.
- **`evaluate` Action** (lines 953–965, 1038–1054, 1084–1092, 1161–1163):
  - **Critical Flaw**: Line 956 executes `@workout_score = @workout_offering.score_for(@student_drift_user)` **without** checking `params[:workout_score_id]`.
  - Even if `practice` had loaded a second attempt, `evaluate` falls back to `score_for`, loads Attempt 1, sees that Attempt 1 is closed (lines 1038–1054), and rejects the submission with `"The time limit or deadline for this workout has passed."`
  - If it proceeds, it associates the new exercise `Attempt` with Attempt 1's `WorkoutScore`.

#### C. `WorkoutsController` (`app/controllers/workouts_controller.rb`)
- **`practice` (Gym)** (lines 1358–1373):
  - Checks `@workout_score = @workout.score_for(current_user, nil, ...)`. If non-nil, reuses the existing score and enforces `closed?`.
- **`evaluate` (Gym)** (lines 1267–1268):
  - `@user_workout_score = WorkoutScore.find_by!(user_id: current_user.id, workout_id: @current_workout.id).score`
  - Uses `find_by!`, which will fail or select an arbitrary attempt if multiple records exist.
- **`create_or_update_offerings`** (lines 1507–1700):
  - Extracts and updates `common[:attempt_limit]` and `common[:time_limit]`, but lacks parameters for `workout_attempt_limit` or `score_to_keep`.

#### D. `CoursesController` (`app/controllers/courses_controller.rb`)
- **`show` and `tab_grades`** (lines 52–60, 168–175, 193–210):
  - Line 207: Groups workout scores by `[workout_offering_id, user_id]`:
    ```ruby
    @workout_scores_by_offering_and_user = WorkoutScore.where(
      workout_offering_id: workout_offering_ids,
      user_id: student_ids
    ).order('updated_at DESC').group_by { |ws| [ws.workout_offering_id, ws.user_id] }
    ```
  - In `app/views/courses/_tab_grades.html.haml`, it does:
    ```haml
    - workout_score = @workout_scores_by_offering_and_user[[wkto.id, student.id]]&.first
    ```
  - Takes `.first` (the most recently updated score), ignoring the course's score-to-keep policy (`highest` vs. `latest`).

---

### 2.4 Views & Exporters Assumptions

1. **`app/views/workouts/show.html.haml`**:
   - Lines 53–66: Renders a single score fraction: `workout_score.score / workout.total_points`.
   - Lines 72–96: If `workout_score.nil? || !workout_score.closed?`, shows `"Start Workout"` or `"Continue Workout"`. If closed, it only displays `"Review Workout"`. There is no `"Retake Workout"` / `"Start Attempt 2"` button or list of attempts.
2. **`app/views/workouts/review.html.haml`**:
   - Lines 2–3: `@workout.score_for(review_user, @workout_offering)`.
   - Shows answers for only one attempt; lacks attempt switcher tabs or dropdown.
3. **`app/views/workouts/_workout.html.haml`** (Dashboard Card):
   - Lines 12–17: Resolves score via `WorkoutScore.find_by(...)` or `score_for(...)` and displays progress for one attempt.
4. **`app/views/exercises/practice.html.haml`**:
   - Submits exercise answers without embedding `workout_score_id` in the evaluate form/action.
5. **Gradebook CSV Exporters**:
   - `app/views/course_offerings/generate_gradebook.csv.shaper:52`
   - `app/views/courses/generate_gradebook.csv.shaper:59`
   - Both execute:
     `WorkoutScore.find_by(user_id: ce.user_id, workout: wkt, workout_offering: workout_offering)`
     which queries a single record.
6. **`app/views/users/show.html.haml`**:
   - Lines 21–36: Loops through `@user.workout_scores`, which would render duplicate workout titles if multiple scores exist for the same offering.

---

## 3. System Design: Multiple Workout Attempts (Canvas LMS Model)

### 3.1 Design Principles & Parity with Canvas Quizzes

In Canvas LMS Quizzes:
1. **Allowed Attempts**: Instructors can set attempts to **1** (default), a specific integer **N** (e.g., 2, 3), or **Unlimited** (`-1` or `nil`).
2. **Score to Keep**: When multiple attempts are permitted, instructors select which grade counts in the gradebook:
   - **Highest** (`highest`): Default in Canvas. Gradebook uses `max(attempt_scores)`.
   - **Latest** (`latest`): Gradebook uses the score of the most recent completed attempt.
3. **Independent Time Limit per Attempt**: If the workout has a time limit (e.g., 30 minutes), each attempt gets its own independent timer countdown starting when that attempt begins.
4. **Hard Deadline Bounds**: Any attempt—even with time remaining on its personal timer—is forcibly closed once the offering's `hard_deadline` passes.
5. **Clean Slate per Attempt**: Each attempt starts with fresh starter code and unanswered questions (no carrying over contaminated answers from previous failed attempts, unless explicitly designed as a multi-stage workout).
6. **Student Accommodations**: Instructors can grant extra attempts to specific students via `StudentExtension` (analogous to Canvas "Moderate Quiz").

---

### 3.2 Conceptual Architecture

```
+--------------------------------------------------------------------------+
|                            WorkoutOffering                               |
|  - workout_attempt_limit: integer (1 = default, nil = unlimited)         |
|  - score_to_keep: enum (:highest, :latest)                     |
|  - time_limit: integer (minutes per attempt)                             |
|  - exercise_attempt_limit: integer (submissions per question)            |
+------------------------------------+-------------------------------------+
                                     | 1
                                     |
                                     | has_many :workout_scores
                                     |
                                     v *
+------------------------------------+-------------------------------------+
|                              WorkoutScore                                |
|  - attempt_number: integer (1, 2, 3...)                                  |
|  - status: enum (:in_progress, :completed, :timed_out)                   |
|  - score: float (score for THIS specific attempt)                        |
|  - started_at: datetime (timer start for this attempt)                   |
|  - completed_at: datetime (submission time for this attempt)             |
+------------------------------------+-------------------------------------+
                                     | 1
                                     |
                                     | has_many :attempts
                                     |
                                     v *
+------------------------------------+-------------------------------------+
|                                Attempt                                   |
|  (Individual question submissions made within this workout attempt)      |
+--------------------------------------------------------------------------+
```

---

### 3.3 Database Schema Changes

All schema changes adhere to CodeWorkout development conventions (using `fk_type` helper for foreign keys).

#### 1. `workout_offerings`
Add workout-level attempt management and scoring policy:
- `workout_attempt_limit` (`integer`, default: `1`, null allowed for unlimited).
- `score_to_keep` (`boolean`, default: `false`). Since there are only two states (`highest` and `latest`), this is representable as a boolean column (`false` = `highest` [default], `true` = `latest`), mapped in ActiveRecord via `enum score_to_keep: { highest: false, latest: true }`.
- *Note on naming*: The existing column `attempt_limit` is currently used for question/exercise attempts. To avoid ambiguity, the workout form and API will expose `workout_attempt_limit` (for workout retakes) and rename or clarify `exercise_attempt_limit` (or retain `attempt_limit` as exercise limit with clear documentation).

#### 2. `student_extensions`
Add student-specific attempt overrides:
- `workout_attempt_limit` (`integer`, default: `nil`): If set, overrides the offering's `workout_attempt_limit`.

#### 3. `workout_scores`
Add attempt sequencing and status:
- `attempt_number` (`integer`, default: `1`, not null).
- New compound index:
  `add_index :workout_scores, [:user_id, :workout_offering_id, :attempt_number], name: 'idx_ws_user_offering_attempt'`

#### Migration Template:
```ruby
class AddMultipleAttemptsSupport < ActiveRecord::Migration[6.0]
  def change
    add_column :workout_offerings, :workout_attempt_limit, :integer, default: 1
    add_column :workout_offerings, :score_to_keep, :boolean, default: false, null: false
    # false = 'highest' (default), true = 'latest'
    
    add_column :student_extensions, :workout_attempt_limit, :integer, default: nil
    
    add_column :workout_scores, :attempt_number, :integer, default: 1, null: false
    add_index :workout_scores, [:user_id, :workout_offering_id, :attempt_number],
              name: 'idx_ws_user_offering_attempt'
  end
end
```

---

### 3.4 Model Business Logic Design

#### A. Enhancing `WorkoutOffering` (`app/models/workout_offering.rb`)

```ruby
class WorkoutOffering < ApplicationRecord
  enum score_to_keep: { highest: false, latest: true }

  # Returns the maximum allowed attempts for a given user (offering default or extension)
  def attempts_allowed_for(user)
    ext = extension_for(user)
    if ext && ext.workout_attempt_limit.present?
      ext.workout_attempt_limit
    else
      self.workout_attempt_limit # nil indicates unlimited
    end
  end

  # Returns all workout scores for a user ordered by attempt number
  def scores_for(user)
    return [] unless user
    if workout_scores.loaded?
      workout_scores.select { |ws| ws.user_id == user.id && ws.workout_id == workout_id }
                    .sort_by { |ws| ws.attempt_number || 1 }
    else
      workout_scores.where(user: user, workout: workout).order(:attempt_number)
    end
  end

  # Returns the currently active (unclosed) attempt, or nil
  def active_score_for(user)
    scores = scores_for(user)
    scores.find { |s| !s.closed? }
  end

  # Returns the latest attempt (open or closed)
  def latest_score_for(user)
    scores_for(user).last
  end

  # Number of attempts already started by the user
  def attempts_taken_for(user)
    scores_for(user).size
  end

  # Number of attempts remaining for the user (Float::INFINITY if unlimited)
  def attempts_left_for(user)
    allowed = attempts_allowed_for(user)
    return Float::INFINITY if allowed.nil? || allowed <= 0
    [allowed - attempts_taken_for(user), 0].max
  end

  # Can the user start a NEW attempt?
  def can_start_new_attempt?(user)
    return false unless user && course_offering.is_enrolled?(user)
    return true if course_offering.is_staff?(user)

    now = Time.zone.now
    opens = opening_date_for(user)
    deadline = hard_deadline_for(user)

    is_open = (opens.nil? || opens <= now) && (deadline.nil? || now <= deadline)
    has_attempts_remaining = attempts_left_for(user) > 0
    no_active_attempt = active_score_for(user).nil?

    is_open && has_attempts_remaining && no_active_attempt && published
  end

  # Effective score to display in gradebook and pass to LTI
  def effective_score_for(user)
    scores = scores_for(user).select { |s| s.score.present? }
    return nil if scores.empty?

    if latest? || score_to_keep.to_s == 'latest'
      scores.last.score.round(2)
    else # 'highest' (default)
      scores.map(&:score).max.round(2)
    end
  end

  # Identifies which WorkoutScore represents the kept score
  def kept_workout_score_for(user)
    scores = scores_for(user).select { |s| s.score.present? }
    return nil if scores.empty?

    if latest? || score_to_keep.to_s == 'latest'
      scores.last
    else # 'highest'
      scores.max_by(&:score)
    end
  end
end
```

#### B. Updating `WorkoutScore` (`app/models/workout_score.rb`)

```ruby
class WorkoutScore < ApplicationRecord
  # Synchronize LTI passback using effective_score_for
  def update_lti
    if self.workout_offering
      effective_score = self.workout_offering.effective_score_for(self.user)
      lms_instance = self.workout_offering.course_offering.lms_instance
    elsif self.lti_workout
      effective_score = self.score
      lms_instance = self.lti_workout.lms_instance
    end

    if lms_instance && self.lis_outcome_service_url && self.lis_result_sourcedid && effective_score
      total_points = ExerciseWorkout.where(workout_id: self.workout_id).sum(:points)
      key = lms_instance.consumer_key
      secret = lms_instance.consumer_secret

      begin
        result = total_points > 0 ? (effective_score / total_points) : 0
        tp = IMS::LTI::ToolProvider.new(key, secret, {
          "lis_outcome_service_url" => "#{self.lis_outcome_service_url}",
          "lis_result_sourcedid" => "#{self.lis_result_sourcedid}"
        })
        tp.post_replace_result!(result)
      rescue => e
        logger.error "LTI Update Failed: #{e.message}"
      end
    end
  end
end
```

---

### 3.5 Attempt Lifecycle & State Machine

```
                  +-----------------------------------+
                  |           Not Started             |
                  +-----------------+-----------------+
                                    |
                    User clicks "Start Workout"
                    (or "Take Workout Again")
                                    |
                                    v
                  +-----------------------------------+
                  |           In Progress             |
                  |  - started_at = Time.now          |
                  |  - timer counting down            |
                  |  - attempts linked to this score  |
                  +-----------------+-----------------+
                                    |
           +------------------------+------------------------+
           |                                                 |
  User clicks "Submit Workout"              Time limit or Hard Deadline expires
           |                                                 |
           v                                                 v
+-----------------------+                         +-----------------------+
|       Completed       |                         |       Timed Out       |
| - completed = true    |                         | - closed? = true      |
| - completed_at = now  |                         +-----------+-----------+
+-----------+-----------+                                     |
            |                                                 |
            +-----------------------+-------------------------+
                                    |
                                    v
                  +-----------------------------------+
                  |        Kept Score Calculated      |
                  | - effective_score_for updated     |
                  | - update_lti pushed to LMS        |
                  +-----------------+-----------------+
                                    |
         +--------------------------+--------------------------+
         | (attempts_left > 0)                                 | (attempts_exhausted)
         v                                                     v
+-------------------------------+             +-------------------------------+
| User sees "Take Workout Again"|             | User sees "Review Workout"    |
| Ready for Attempt N+1         |             | No further attempts permitted |
+-------------------------------+             +-------------------------------+
```

---

## 4. Detailed File-by-File List of Required Changes

### 4.1 Database Migrations
- `db/migrate/YYYYMMDDHHMMSS_add_multiple_attempts_to_workout_offerings.rb`:
  - Add `workout_attempt_limit` (integer, default: 1) to `workout_offerings`.
  - Add `score_to_keep` (boolean, default: false [highest]) to `workout_offerings`.
  - Add `workout_attempt_limit` (integer, default: nil) to `student_extensions`.
  - Add `attempt_number` (integer, default: 1, null: false) to `workout_scores`.
  - Add index `[:user_id, :workout_offering_id, :attempt_number]` to `workout_scores`.

---

### 4.2 Models

1. **`app/models/workout_offering.rb`**:
   - Add enum for `score_to_keep`: `{ highest: false, latest: true }`.
   - Update `score_for(user)`: Retain for backward compatibility, but make it return the *kept score* record or delegate to `kept_workout_score_for(user)`.
   - Add new methods:
     - `scores_for(user)`
     - `active_score_for(user)`
     - `latest_score_for(user)`
     - `effective_score_for(user)`
     - `kept_workout_score_for(user)`
     - `attempts_allowed_for(user)`
     - `attempts_taken_for(user)`
     - `attempts_left_for(user)`
     - `can_start_new_attempt?(user)`
   - Refactor `can_be_practiced_by?(user)`:
     - Replace `return false if workout_score && workout_score.closed?` with a check that returns `true` if an active unclosed score exists OR if `can_start_new_attempt?(user)` is true.
   - Refactor `can_be_seen_by?(user)`:
     - Check `active_score_for(user)` instead of closing out visibility when Attempt 1 finishes.

2. **`app/models/workout_score.rb`**:
   - Add scope `:for_user_and_offering(user, offering)` ordered by `attempt_number`.
   - Before validation / creation: Auto-populate `attempt_number` as `(existing_attempts.maximum(:attempt_number) || 0) + 1`.
   - In `update_lti`: Calculate score using `workout_offering.effective_score_for(user)` instead of `self.score`.

3. **`app/models/student_extension.rb`**:
   - Support `workout_attempt_limit` in `create_or_update!`.

4. **`app/models/user.rb`**:
   - Update `migrate_workout_scores_and_extensions`: Handle migrating multiple workout scores to a sister offering without halting on "duplicate workout score".
   - Update `merge`: Preserve multiple attempt records when merging accounts.

---

### 4.3 Controllers

1. **`app/controllers/workout_offerings_controller.rb`**:
   - **New Action `start_attempt`**:
     ```ruby
     def start_attempt
       @workout_offering = WorkoutOffering.find(params[:id])
       if @workout_offering.can_start_new_attempt?(current_user)
         next_num = @workout_offering.attempts_taken_for(current_user) + 1
         new_score = WorkoutScore.create!(
           user: current_user,
           workout_offering: @workout_offering,
           workout: @workout_offering.workout,
           attempt_number: next_num,
           score: 0,
           exercises_completed: 0,
           exercises_remaining: @workout_offering.workout.exercises.count,
           started_at: Time.zone.now,
           lis_outcome_service_url: params[:lis_outcome_service_url] || session[:lis_outcome_service_url],
           lis_result_sourcedid: params[:lis_result_sourcedid] || session[:lis_result_sourcedid]
         )
         redirect_to organization_workout_offering_exercise_path(
           id: @workout_offering.workout.first_exercise.id,
           workout_offering_id: @workout_offering.id,
           workout_score_id: new_score.id,
           ...
         )
       else
         redirect_to organization_workout_offering_path(@workout_offering),
                     alert: 'You cannot start a new attempt at this time.'
       end
     end
     ```
   - **`practice` Action**:
     - Check for an existing `active_score_for(current_user)`.
     - If none exists:
       - If `attempts_taken_for == 0` and can practice: auto-create Attempt 1.
       - If past attempts exist and `can_start_new_attempt?`: redirect to `show` with the "Take Workout Again" option, or create Attempt N+1 if requested.
       - If attempts exhausted: redirect to `review` or `show` with notice.
   - **`show` Action**:
     - Provide `@past_scores = @workout_offering.scores_for(current_user)`.
     - Provide `@active_score = @workout_offering.active_score_for(current_user)`.
     - Provide `@effective_score = @workout_offering.effective_score_for(current_user)`.
     - Provide `@can_retake = @workout_offering.can_start_new_attempt?(current_user)`.
   - **`review` Action**:
     - Accept optional `params[:workout_score_id]` or `params[:attempt_number]`.
     - Default to `@workout_offering.kept_workout_score_for(review_user)` or latest attempt.
     - Load all student attempts into `@all_scores` to populate the attempt selection dropdown.

2. **`app/controllers/exercises_controller.rb`**:
   - **`practice` Action**:
     - Ensure `@workout_score` is resolved strictly via `params[:workout_score_id]` whenever present, falling back to `active_score_for` or `latest_score_for`.
     - Enforce timeout/closed redirects against that specific `@workout_score`.
   - **`evaluate` Action**:
     - **Fix critical bug**: Look for `params[:workout_score_id]` before calling `score_for`.
     - Bind the newly created `Attempt` to `params[:workout_score_id]`.
     - Record attempt and verify closed status against that specific score record.

3. **`app/controllers/workouts_controller.rb`**:
   - **`create_or_update_offerings`**:
     - Extract `params[:workout_attempt_limit]` and `params[:score_to_keep]` from form and YAML.
     - Support YAML section attributes:
       ```yaml
       sections:
         - section: CS 1114
           due: 2026-10-20 11:59 PM
           workout_attempts: 2
           score_to_keep: highest
       ```
     - Support student extension YAML attributes:
       ```yaml
       extensions:
         - students: [student@vt.edu]
           workout_attempts: 3
       ```

4. **`app/controllers/courses_controller.rb`**:
   - In `tab_grades`: Calculate grades using `wkto.effective_score_for(student)` instead of taking `.first` of arbitrary updated_at ordering.

---

### 4.4 Views & User Interface

1. **`app/views/workouts/show.html.haml`**:
   - **Attempt Summary Header**:
     - Display: "Attempts Allowed: X | Attempts Taken: Y | Score to Keep: Highest".
     - Display: "Recorded Grade: [Effective Score] / [Total Points]".
   - **History Table** (when attempts > 0):
     - Table listing each attempt:
       - Attempt # (1, 2, ...)
       - Date Started / Date Submitted
       - Score (with "Kept Score" badge next to the winning attempt)
       - Link to "Review Attempt"
   - **Action Buttons**:
     - If active attempt in progress: Button `"Resume Workout (Attempt X)"` (green/primary).
     - If previous attempt closed and `can_start_new_attempt?`: Button `"Take Workout Again (Attempt X+1)"` (blue).
     - If attempts exhausted or closed: Button `"Review Workout"`.

2. **`app/views/workouts/review.html.haml`**:
   - Add an **Attempt Selector** navigation bar (tabs or dropdown):
     - "Attempt 1: 75/100"
     - "Attempt 2: 95/100 (Kept Grade)"
   - Clicking an attempt reloads review for that specific `workout_score_id`.

3. **`app/views/exercises/practice.html.haml`**:
   - Header badge: `"Attempt X of Y"`.
   - Ensure the evaluation AJAX form includes a hidden field or URL param: `workout_score_id: @workout_score.id`.

4. **`app/views/courses/_tab_grades.html.haml`**:
   - Render `wkto.effective_score_for(student)`.
   - Add an attempt counter badge (e.g., `85.0 (att. 2/2)`).

5. **`app/views/workouts/_form.html.haml` & CoffeeScript**:
   - Add field: `"Allowed Workout Attempts"` (number input, placeholder: "1", hint: "Leave blank or 1 for single attempt; set >1 or 0 for unlimited").
   - Add dropdown or radio toggle: `"Score to Keep"`:
     - `Highest Score` (default)
     - `Latest Attempt`
   - Dynamically toggle "Score to Keep" visibility via JavaScript when workout attempts > 1.

6. **Gradebook CSV Exporters**:
   - `app/views/course_offerings/generate_gradebook.csv.shaper`
   - `app/views/courses/generate_gradebook.csv.shaper`
   - Replace `WorkoutScore.find_by(...)` with `workout_offering.effective_score_for(student)`.

---

### 4.5 Routing (`config/routes.rb`)

Add a POST route to explicitly start a subsequent attempt:
```ruby
resources :workout_offerings do
  member do
    post :start_attempt
    get :activity_log
  end
end
```
And mirror in organizational course offering hierarchy:
```ruby
scope '/org/:organization_id/:course_id/:term_id' do
  resources :workout_offerings do
    member do
      post :start_attempt
    end
  end
end
```

---

## 5. Edge Cases & Special Considerations

1. **Concurrent Attempts**:
   - A student should not be able to open two browser tabs and run Attempt 1 and Attempt 2 simultaneously. `can_start_new_attempt?` strictly verifies that no active (unclosed) score exists. If an unclosed score exists, the system forces the student to resume that attempt.
2. **Timer Interruption vs. Expiration**:
   - If a student leaves midway through Attempt 2, the timer continues running from `started_at`. When they return, if elapsed time > `time_limit`, Attempt 2 is automatically closed and they cannot continue editing it.
3. **Hard Deadline Clamping**:
   - Even if Attempt 2 has 20 minutes left on its personal time limit, if the assignment's `hard_deadline` occurs in 5 minutes, remaining time is clamped to 5 minutes (`[time_limit_remaining, hard_deadline - now].min`).
4. **IP and User Agent Locking**:
   - Each `WorkoutScore` stores its own `last_ip_address` and `last_user_agent_id`. If an exam uses LockDown Browser or an IP restriction, both Attempt 1 and Attempt 2 independently validate and lock to the client session.
5. **Regrading / Rescoring**:
   - When an instructor regrades an exercise version or edits workout point values, calling `retotal` or `rescore` on each `WorkoutScore` updates that individual attempt, which subsequently triggers `effective_score_for` and pushes the updated kept score to LMS via LTI.

---

## 6. Implementation Checklist & Phase Plan

| Phase | Tasks |
| :--- | :--- |
| **Phase 1: Database Migration** | • Create migration for `workout_offerings`, `student_extensions`, and `workout_scores`<br>• Run migration locally and verify schema |
| **Phase 2: Model Logic** | • Implement `scores_for`, `effective_score_for`, `can_start_new_attempt?` in `WorkoutOffering`<br>• Update `WorkoutScore#update_lti` to sync effective score<br>• Refactor `can_be_practiced_by?` and `can_be_seen_by?` |
| **Phase 3: Controller Actions** | • Add `start_attempt` action in `WorkoutOfferingsController`<br>• Fix `ExercisesController#evaluate` to accept and use `params[:workout_score_id]`<br>• Update `WorkoutOfferingsController#practice` and `review` |
| **Phase 4: Views & UX** | • Update `workouts/show.html.haml` with attempts table and "Take Again" button<br>• Add attempt switcher in `workouts/review.html.haml`<br>• Update `_tab_grades.html.haml` and CSV gradebook exports<br>• Add workout attempt limit and score-to-keep inputs in `workouts/_form.html.haml` |
| **Phase 5: Automated Testing** | • Model specs for `WorkoutOffering` multi-attempt calculations and score policies<br>• Controller specs for `start_attempt`, timeout closures, and attempt exhaustion<br>• Request specs verifying LTI grade passback uses kept score |
