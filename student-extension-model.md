# StudentExtension Model & Deadline Calculation Logic

## 1. Overview

The `StudentExtension` model represents individualized schedule exceptions and extensions granted to specific students for a specific assignment offering (`WorkoutOffering`). In educational environments, students frequently require accommodations—such as disability service accommodations, extensions for illness, or individualized start dates. `StudentExtension` overrides or extends the default dates and constraints defined on a `WorkoutOffering` on a per-student basis.

---

## 2. Database Schema (`db/schema.rb`)

The `student_extensions` table stores the override values for a given `(user_id, workout_offering_id)` pair.

### Table Definition

```ruby
create_table "student_extensions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
  t.integer  "user_id"
  t.integer  "workout_offering_id"
  t.datetime "soft_deadline"
  t.datetime "hard_deadline"
  t.datetime "created_at"
  t.datetime "updated_at"
  t.integer  "time_limit"
  t.datetime "opening_date"
  t.index ["user_id"], name: "index_student_extensions_on_user_id"
  t.index ["workout_offering_id"], name: "index_student_extensions_on_workout_offering_id"
end
```

### Column Descriptions

| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | `integer` / `bigint` | Primary key identifier for the extension record. |
| `user_id` | `integer` / `bigint` | Foreign key referencing the student (`users.id`). |
| `workout_offering_id` | `integer` / `bigint` | Foreign key referencing the assignment offering (`workout_offerings.id`). |
| `opening_date` | `datetime` | Individualized date and time when the workout becomes accessible to the student. |
| `soft_deadline` | `datetime` | Individualized main due date for the student. Submissions after this date may incur penalties if allowed. |
| `hard_deadline` | `datetime` | Individualized absolute cutoff date and time. Submissions are strictly prohibited after this point. |
| `time_limit` | `integer` | Individualized duration limit (in minutes) for completing the workout once started. |
| `created_at` | `datetime` | Timestamp when the extension was created. |
| `updated_at` | `datetime` | Timestamp when the extension was last updated. |

### Indexes & Foreign Keys

- **Indexes**:
  - `index_student_extensions_on_user_id` on column `user_id`
  - `index_student_extensions_on_workout_offering_id` on column `workout_offering_id`
- **Foreign Keys**:
  - `add_foreign_key "student_extensions", "users", name: "student_extensions_user_id_fk"`
  - `add_foreign_key "student_extensions", "workout_offerings", name: "student_extensions_workout_offering_id_fk"`

---

## 3. Model Class & Entity Relationships

The ActiveRecord model is defined in `app/models/student_extension.rb`.

### Model Class Definition

```ruby
class StudentExtension < ApplicationRecord
  belongs_to :user
  belongs_to :workout_offering

  # Class method to create or update an extension record from form parameters
  def self.create_or_update!(student, workout_offering, opts)
    ...
  end
end
```

### Entity Relationships

```
  +------------------+         1 : N         +----------------------+
  |       User       | --------------------> |   StudentExtension   |
  |    (Student)     |                       +----------------------+
  +------------------+                                  |
           ^                                            | N : 1
           |                                            v
           |           N : M (through extensions)   +----------------------+
           +======================================> |   WorkoutOffering    |
                                                    +----------------------+
                                                                |
                                             +------------------+------------------+
                                             | N : 1                               | N : 1
                                             v                                     v
                                    +-----------------+                   +-----------------+
                                    |     Workout     |                   | CourseOffering  |
                                    +-----------------+                   +-----------------+
```

1. **`User` (`app/models/user.rb`)**:
   - `has_many :student_extensions`
   - `has_many :workout_offerings, through: :student_extensions`
   - Represents the student receiving the extension.

2. **`WorkoutOffering` (`app/models/workout_offering.rb`)**:
   - `has_many :student_extensions`
   - `has_many :users, through: :student_extensions`
   - Represents the course-specific assignment offering that holds the default baseline dates and parameters (`opening_date`, `soft_deadline`, `hard_deadline`, `time_limit`).

3. **`CourseOffering` (`app/models/course_offering.rb`)**:
   - Associated through `WorkoutOffering` (`belongs_to :course_offering`).
   - Determines student enrollment and course staff permissions.

4. **`WorkoutScore` (`app/models/workout_score.rb`)**:
   - Tracks a student's session and score on a `WorkoutOffering`. Uses the effective deadlines and time limits calculated from the student's extension to determine whether the session is closed.

---

## 4. Effective Deadline and Date Calculation Logic

When an individual student accesses a `WorkoutOffering`, the application resolves the effective parameters by checking for an existing `StudentExtension` for that `(user, workout_offering)` pair.

### 4.1 Effective Opening Date (`opening_date_for`)

Determines when the workout becomes visible and accessible to the student:

```ruby
def opening_date_for(user)
  user_extension = StudentExtension.find_by(user: user, workout_offering: self)
  user_extension.andand.opening_date || self.opening_date
end
```

**Resolution Priority:**
1. If the student has a `StudentExtension` with an `opening_date`, use `user_extension.opening_date`.
2. Otherwise, fallback to the baseline `workout_offering.opening_date`.
3. If neither is set (`nil`), the workout is open immediately / always open.

---

### 4.2 Effective Soft Deadline

The soft deadline represents the expected completion date (after which submissions may be flagged late or subject to late penalties):
- If `StudentExtension#soft_deadline` is set, it serves as the student's individualized soft deadline.
- Otherwise, the baseline `WorkoutOffering#soft_deadline` is used.
- Furthermore, the student extension soft deadline serves as an input to the effective hard deadline calculation (described below).

---

### 4.3 Effective Hard Deadline (`hard_deadline_for`)

The hard deadline is the strict cutoff after which no submissions or practice attempts are permitted. The calculation implements a 3-tier fallback algorithm in `WorkoutOffering#hard_deadline_for`:

```ruby
def hard_deadline_for(user)
  user_ext = extension_for(user)

  # (1) Student extension hard deadline
  return user_ext.hard_deadline if user_ext.andand.hard_deadline
  
  # (2) If offering has a hard deadline, extend it if the student has a later soft deadline
  if self.hard_deadline
    return [self.hard_deadline, user_ext.andand.soft_deadline].compact.max
  end
  
  # (3) No hard deadline set
  nil
end
```

**Step-by-Step Logic:**
1. **Tier 1 (Explicit Extension Hard Deadline):** If the student has an extension with a non-nil `hard_deadline`, return that exact timestamp.
2. **Tier 2 (Offering Hard Deadline with Student Soft Deadline Extension):** If no student hard deadline is specified, but the base offering has a `hard_deadline`:
   - If the student was granted an extended soft deadline that extends past the original offering hard deadline, their effective hard deadline expands to match that soft deadline.
   - Otherwise, the offering's hard deadline is retained.
3. **Tier 3 (No Hard Deadline):** If neither an offering hard deadline nor a student hard deadline exists, return `nil` (meaning no cutoff date, allowing practice and late submissions according to policy).

---

### 4.4 Effective Time Limit (`time_limit_for`)

For timed assignments, individual time limits (such as 1.5x or 2x time accommodations) are resolved as:

```ruby
def time_limit_for(user)
  user_extension = StudentExtension.find_by(user: user, workout_offering: self)
  user_extension.andand.time_limit || self.time_limit
end
```

**Resolution Priority:**
1. `user_extension.time_limit` (if present).
2. Baseline `workout_offering.time_limit`.

---

## 5. Downstream Applications of Effective Extension Data

The calculated values directly govern student access and workflow state:

1. **Practice & Access Control (`WorkoutOffering#can_be_practiced_by?`)**:
   - Verifies course enrollment.
   - Evaluates whether `Time.zone.now` is within `[opening_date_for(user), hard_deadline_for(user)]`.
2. **Visibility Control (`WorkoutOffering#can_be_seen_by?`)**:
   - Ensures the offering is published, the user is enrolled, `opening_date_for(user) <= now`, and review rules or `hard_deadline_for(user)` policies are met.
3. **Attempt & Session Expiration (`WorkoutScore#closed?`)**:
   - A workout score session is marked closed when either:
     - The elapsed time (`(now - started_at) / 60.0`) exceeds `time_limit_for(user)`, or
     - The current time exceeds `hard_deadline_for(user)`.
4. **Aggregate Course Shutdown (`WorkoutOffering#ultimate_deadline`)**:
   - To determine the final date after which no student in the course can submit, `WorkoutOffering#ultimate_deadline` finds the maximum date across the offering's deadlines and all student extensions:
     ```ruby
     [ deadline,
       student_extensions.maximum(:hard_deadline),
       student_extensions.maximum(:soft_deadline)
     ].compact.max
     ```
