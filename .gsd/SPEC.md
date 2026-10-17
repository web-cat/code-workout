# Multiple Workout Attempts Specification

## Status: FINALIZED

## 1. Overview
Currently, workouts in CodeWorkout can only be attempted once, with a single `WorkoutScore` record per `(user_id, workout_offering_id)`. For quizzes, timed practice assessments, and mastery learning, workouts need to support multiple attempts—similar to Canvas LMS quizzes—where each attempt corresponds to a distinct `WorkoutScore`.

This feature allows instructors to configure `workout_attempt_limit` (e.g. 1, 2, 3... or unlimited/nil) and `score_to_keep` (`highest` [default] or `latest`, stored as a boolean). Each attempt has its own independent countdown timer bounded by the offering's hard deadline. Gradebook displays and LMS grade passback via LTI use the kept/effective score. Instructors can also grant extra attempts to individual students via `StudentExtension`.

---

## 2. Functional Requirements

### 2.1 Attempt Controls & Configuration
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

### 2.2 Attempt Lifecycle & Independent Timers
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

### 2.3 Access & Eligibility Rules (`WorkoutOffering`)
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

### 2.4 Kept / Effective Score Calculation & LTI Grade Passback
- `effective_score_for(user)`:
  - When `score_to_keep == 'highest'` (default): `max(completed_attempt_scores)`.
  - When `score_to_keep == 'latest'`: score of the latest attempt.
- `kept_workout_score_for(user)`: Returns the `WorkoutScore` instance corresponding to the kept score.
- `score_for(user)`: Preserved for backward compatibility, returning `kept_workout_score_for(user)`.
- `WorkoutScore#update_lti`:
  - Posts `effective_score_for(user)` divided by total points to the LMS `lis_outcome_service_url`.
  - Prevents a lower second attempt from decreasing the grade in Canvas when policy is "Highest".

### 2.5 Controller Actions & Attempt Binding
- **New Action `WorkoutOfferingsController#start_attempt`**:
  - POST endpoint to start a subsequent attempt.
  - Validates `can_start_new_attempt?(current_user)`.
  - Creates new `WorkoutScore` with `attempt_number: attempts_taken + 1`.
  - Redirects to first exercise of the workout.
- **`WorkoutOfferingsController#practice`**:
  - Resolves active attempt or creates Attempt 1 if none taken yet.
  - If past attempts exist and no active attempt, redirects to `show` with "Take Workout Again" option.
- **`ExercisesController#evaluate`**:
  - **CRITICAL BUG FIX**: Must check `params[:workout_score_id]` before calling `@workout_offering.score_for`.
  - Binds new `Attempt` directly to `params[:workout_score_id]`.
  - Validates closed status against that specific `workout_score`.
- **`WorkoutOfferingsController#review` & `WorkoutsController#review`**:
  - Accepts optional `params[:workout_score_id]` or `params[:attempt_number]` to review past attempts.
  - Defaults to kept workout score.

### 2.6 Views & UX
- `app/views/workouts/show.html.haml`:
  - Attempt summary header (Allowed, Taken, Score to Keep, Kept Grade).
  - Attempt history table with attempt numbers, dates, scores, and "Kept Score" badge.
  - Dynamic action button: "Resume Workout (Attempt X)" vs "Take Workout Again (Attempt X+1)" vs "Review Workout".
- `app/views/workouts/review.html.haml`:
  - Attempt selector (links/dropdown) to review individual attempts.
- `app/views/courses/_tab_grades.html.haml` & CSV Gradebook Exporters:
  - Display `effective_score_for(student)`.

---

## 3. Database Schema Changes
1. `workout_offerings`:
   - `workout_attempt_limit` (`integer`, default: `1`)
   - `score_to_keep` (`boolean`, default: `false`, `null: false`)
2. `student_extensions`:
   - `workout_attempt_limit` (`integer`, default: `nil`)
3. `workout_scores`:
   - `attempt_number` (`integer`, default: `1`, `null: false`)
   - Index `[:user_id, :workout_offering_id, :attempt_number]`
