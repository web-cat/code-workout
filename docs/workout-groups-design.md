# Hierarchical Workout Grouping: Workout Series Architectural Design

## 1. Naming Analysis: Selecting "Workout Series"

### 1.1 Criteria & Constraints

When establishing an overarching grouping mechanism for workouts in CodeWorkout:
1. **Avoid Human-Centric Terms**: Names like `team`, `squad`, `crew`, or `cohort` suggest student groups, study partners, or instructor teams, creating immediate conceptual confusion with user groups and course rosters.
2. **Avoid Overly Generic Abstract Terms**: Names like `cluster`, `group`, `set`, `collection`, or `pack` are bland, computer-science-heavy, or already overloaded (e.g., Ruby's `Set`, database `UserGroup`, CodeWorkout's `ExerciseCollection`).
3. **Avoid Ill-Fitting or Eccentric Metaphors**: Names like `gaggle`, `batch`, `bundle`, or `flock` either sound whimsical or suggest batch background jobs.
4. **Support Arbitrary Hierarchical Nesting**: The term must feel natural when nested recursively (e.g., a "parent series" containing "sub-series").
5. **Resonate with CodeWorkout’s Metaphor & Higher Education**: The name should naturally bridge CodeWorkout's **fitness/gym metaphor** and **academic course structure**.

---

### 1.2 Evaluation of Candidate Names

| Candidate | Domain Origin | Strengths | Limitations | Rating |
| :--- | :--- | :--- | :--- | :--- |
| **Series**<br>*(Workout Series)* | **Pedagogical / Athletic** | **Universally natural in higher education and course syllabi**: *"Lab Series"*, *"Quiz Series"*, *"Homework Series"*, *"Exam Series"*. In fitness and athletics, a *series* represents a coordinated progression of workout movements performed toward specific training adaptations. | Sub-series must be clearly labeled when nesting, but hierarchy is intuitive. | **Selected Standard** ⭐⭐⭐⭐⭐ |
| **Routine**<br>*(Workout Routine)* | **Fitness / Gym** | Leans heavily into the gym metaphor (e.g., *"Leg Day Routine"*). Easily nests: *"Warmup Routine"*, *"Core Routine"*. | Less familiar to university faculty outside of athletic contexts. | **Strong Metaphor Alternative** ⭐⭐⭐⭐ |
| **Suite**<br>*(Workout Suite)* | **Architecture / Software** | Dignified, professional, and precise (similar to a *test suite* or *application suite*). Sub-suites nest cleanly (`Suite` -> `Sub-suite`). | Lacks the fitness theme, but sounds exceptionally clean. | **Strong Architectural Alternative** ⭐⭐⭐⭐ |
| **Module** | **Pedagogical / LMS** | Universal standard across higher education LMSs (Canvas, edX). Instructors instantly recognize it. | Generic across all platforms; does not evoke CodeWorkout's unique gym theme. | **Academic Alternative** ⭐⭐⭐⭐ |
| **Circuit** | **Fitness / Gym** | Great gym metaphor (circuit training). | Implies a sequential loop where stations must be completed in continuous rotational order, which does not match all academic assignments. | **Moderate** ⭐⭐⭐ |
| **Track** | **Curriculum / Pathway** | Connotes a progression pathway (e.g., *"Advanced Track"*). | Better suited for entire degree concentrations or learning paths than hierarchical assignment folders. | **Moderate** ⭐⭐⭐ |

---

### 1.3 Decision: `WorkoutSeries`

**Selected Term: `WorkoutSeries` (plural: `WorkoutSeries`, membership: `WorkoutSeriesMembership`, section offering: `WorkoutSeriesOffering`).**

*Key Rationale:*
1. **Natural Syllabi Alignment**: College syllabi routinely refer to "the Weekly Lab Series", "the Quiz Series", and "the Practice Exercise Series". Instructors do not need training to understand what a "Workout Series" is.
2. **Gym & Athletic Periodization**: In physical training, athletes perform progressive *workout series* (e.g., conditioning series, strength series, interval series) designed to develop mastery over time.
3. **Seamless Hierarchy**:
   - **Midterm 1 Assessment Series** (Root Series)
     - **Review & Practice Series** (Sub-series)
       - Workout 1: Basic Control Flow
       - Workout 2: Loops & Arrays
     - **Timed In-Class Exam Series** (Sub-series)
       - Midterm Exam Workout

---

## 2. Problem Statement & Multi-Section Semester Context

### 2.1 The Multi-Offering Problem in Multi-Section Courses

In university courses (such as introductory programming with 500–2,000 students):
- A single **`Course`** (e.g., CS 1114) in a single **`Term`** (e.g., Fall 2026) is taught across **multiple `CourseOffering`s** (Section 001, Section 002, Section 003, Honors Section 091).
- A unified **teaching team** (lead professor, co-instructors, and head teaching assistants in the course's `UserGroup`) coordinates all sections.
- The instructors assign dozens of workouts: weekly labs, daily practice drills, timed in-class quizzes, and major exams.
- Currently, settings (time limits, LockDown Browser requirements, IP restrictions, attempt policies, and deadlines) must be configured **on every single `WorkoutOffering` individually**, or repeated section-by-section in YAML strings.

### 2.2 The Student Accommodation & Extension Problem

University courses must regularly support students with **disability accommodations (e.g., SSD / ADA accommodations), athletic travel schedules, or medical leaves**:
- **Accommodations granted by university offices**:
  - **Time limit multipliers**: 1.5x time (time-and-a-half) or 2.0x time (double time) on all timed quizzes and exams.
  - **Location / IP flexibility**: Permission to test in an accessible testing center or remote room (`ips: any` or dedicated testing center CIDR).
  - **Assistive Browser Access**: Use of screen readers or assistive tools incompatible with LockDown Browser (`allowed_user_agents: any`).
  - **Attempt overrides**: Extra allowed workout attempts for mastery practice.
  - **Universal Deadline Extensions**: +2 days or +48 hours on all assignments throughout the semester.
- **Current Limitation in CodeWorkout**:
  - `StudentExtension` records are attached strictly per-`(user_id, workout_offering_id)`.
  - If a course has 30 workouts in a semester, instructors or TAs must manually create 30 separate `StudentExtension` records for every accommodated student!
  - If an instructor introduces a new workout mid-semester, they often forget to create an extension for accommodated students, leading to stressful, unfair exam lockouts.

### 2.3 Requirements for the Comprehensive Solution

1. **Hierarchical Tree Structure**: Series can be nested arbitrarily deep ($N$ levels: Root Series $\rightarrow$ Child Series $\rightarrow$ Workouts).
2. **Course Offering as Top-Level Root**: A `CourseOffering` can be treated as the root series offering for all workout offerings in that section.
3. **Cascading Settings & Inheritance**: Policy settings defined at parent series or the course offering level automatically cascade down to child series and member workouts unless explicitly overridden.
4. **Unified Scoped Student Extensions**: Unify one-off extensions and semester accommodations into a single **`StudentExtension`** model that supports hierarchical scoping (Workout Offering $\rightarrow$ Workout Series $\rightarrow$ Course Offering) with both absolute timestamps and relative modifiers.
5. **Shared Across Course Offerings**: Curricular series hierarchies are authored **once** for the course/term by the teaching staff and instantiated across all section offerings with relative meeting schedule offsets.

---

## 3. Domain Model & Database Schema

### 3.1 Entity Relationship Diagram

```
+--------------------------------------------------------------------------+
|                                  Course                                  |
+------------------------------------+-------------------------------------+
                                     | 1
                                     | has_many :workout_series
                                     v *
+------------------------------------+-------------------------------------+
|                              WorkoutSeries                               |
|  - id: bigint                                                            |
|  - course_id: bigint                                                     |
|  - term_id: bigint (optional; nil = reusable course-wide template)       |
|  - parent_id: bigint (self-referential foreign key)                      |
|  - name: string                                                          |
|  - description: text                                                     |
|  - position: integer (ordering among siblings)                           |
|  - ancestry: string (materialized path for O(1) subtree traversal)       |
|                                                                          |
|  # Inheritable Workout Configuration Attributes:                         |
|  - time_limit: integer                                                   |
|  - workout_attempt_limit: integer                                        |
|  - score_to_keep: string                                                 |
|  - policy_values: bigint (bitmask of 12 boolean choices)                 |
|  - policy_mask: bigint (tri-state override mask; 0 = inherit, 1 = set)    |
|  - allowed_ips: text                                                     |
|  - allowed_user_agents: text                                             |
|  - published: boolean (series gate: true = open, false = closed draft)    |
+--------------------+-------------------------------+---------------------+
                     | 1                             | 1
                     | has_many                      | has_many
                     v *                             v *
+--------------------+------------------+   +--------+---------------------+
|      WorkoutSeriesMembership          |   |        WorkoutSeriesOffering |
|  - workout_series_id: bigint          |   |  - workout_series_id: bigint |
|  - workout_id: bigint                 |   |  - course_offering_id: bigint|
|  - position: integer                  |   |  - opening_date: datetime    |
|  - override_settings: json / text     |   |  - soft_deadline: datetime   |
+--------------------+------------------+   |  - hard_deadline: datetime   |
                     |                      +------------------------------+
                     | references                                  | 1
                     v                                             | has_many
+--------------------+------------------+                          v *
|               Workout                |    +------------------------------+
+--------------------+-----------------+    |       StudentExtension       |
                     | 1                    |  - user_id: bigint           |
                     |                      |  - course_offering_id: bigint|
                     | has_many             |  - workout_series_id: bigint |
                     v *                    |    (optional: nil = course)  |
+--------------------+-----------------+    |  - workout_offering_id: int  |
|          WorkoutOffering             |    |    (optional: nil = series)  |
|  - workout_id: bigint                |    |                              |
|  - course_offering_id: bigint        |    |  # Absolute Overrides:       |
|  - workout_series_offering_id: bigint|    |  - opening_date: datetime    |
|  - opening_date: datetime            |    |  - soft_deadline: datetime   |
|  - soft_deadline: datetime           |    |  - hard_deadline: datetime   |
|  - hard_deadline: datetime           |    |  - time_limit: integer       |
|  - time_limit: integer               |    |                              |
|  - workout_attempt_limit: integer    |    |  # Relative Modifiers:       |
|  - allowed_ips: text                 |    |  - time_limit_multiplier: flt|
|  - allowed_user_agents: text         |    |  - extra_time_minutes: int   |
+--------------------+-----------------+    |  - deadline_offset_hours: int|
                     | 1                    |  - extra_attempts: integer   |
                     | has_many             |                              |
                     v *                    |  # Policy Bypasses:          |
                     +--------------------->|  - allowed_ips: text         |
                       (specific assignment |  - allowed_user_agents: text |
                        extension link)     |  - workout_attempt_limit: int|
                                            +------------------------------+
```

---

### 3.2 Accommodating Course Offering as Top-Level Workout Series

Can a `CourseOffering` be interpreted as a top-level workout series? **Yes, seamlessly.**

In CodeWorkout, a `CourseOffering` represents a specific section/instance of a course in a term (e.g., CS 1114, Fall 2026, Section 001). Treating `CourseOffering` as the **Root Scope** of the series hierarchy provides an elegant, unified architecture:
```
CourseOffering (Section Level Root Scope)
  ├── WorkoutSeriesOffering: "Assessments" (Branch Series)
  │     ├── WorkoutSeriesOffering: "Weekly Quizzes" (Leaf Series)
  │     │     ├── WorkoutOffering: "Quiz 1"
  │     │     └── WorkoutOffering: "Quiz 2"
  │     └── WorkoutOffering: "Midterm Exam"
  └── Standalone WorkoutOffering: "Diagnostic Pre-test" (Directly under CourseOffering root)
```
- **Direct Attachment**: Any `WorkoutOffering` with `workout_series_offering_id: nil` attaches directly to the `CourseOffering` as a top-level standalone assignment.
- **Section-Wide Default Policies**: `CourseOffering` gains optional default configuration fields (`default_allowed_ips`, `default_allowed_user_agents`, `default_policy_values`, `default_policy_mask`, `default_workout_attempt_limit`).
- **Cascading Fallback**: When resolving any configuration parameter for a workout, the resolution chain walks:
  `WorkoutOffering` $\rightarrow$ `WorkoutSeriesOffering` $\rightarrow$ Parent Series $\rightarrow$ `CourseOffering` $\rightarrow$ System Default Baseline.

---

### 3.3 Unified Model: Generalizing `StudentExtension`

#### Analysis: One Model vs. Two Models
A separate `StudentAccommodation` model would duplicate fields (`user_id`, `allowed_ips`, `allowed_user_agents`, `workout_attempt_limit`) and force an artificial division between an "extension" (ad-hoc) and an "accommodation" (standing policy).

Instead, generalizing **`StudentExtension`** to support **hierarchical scoping** unifies both concepts under a single domain entity:
- **Assignment Scope** (`workout_offering_id` is present):
  Acts as an individual assignment extension. Supports both absolute dates (e.g., `hard_deadline: "2026-10-25 11:59 PM"`, `time_limit: 45`) and relative modifiers.
- **Series Scope** (`workout_series_id` is present, `workout_offering_id` is `nil`):
  Acts as an accommodation/extension for all workouts within that series and its sub-series. Uses relative rules (e.g., `time_limit_multiplier: 1.5`, `deadline_offset_hours: 48`).
- **Course Offering Scope** (`course_offering_id` is present, both series and workout offering are `nil`):
  Acts as a universal, semester-long course accommodation (e.g., Jane Doe gets 1.5x time and IP bypass on every quiz, lab, and exam in the course).

#### Enhancements to Existing `StudentExtension` Handling
To support this unified model without breaking legacy behavior:

1. **Schema Evolution**:
   - `workout_offering_id` becomes **nullable** (`null: true`).
   - Add `course_offering_id` (`references :course_offerings, null: false`) to anchor all extensions to their section context.
   - Add `workout_series_id` (`references :workout_series, null: true`).
   - Add relative modifiers: `time_limit_multiplier` (`float`), `extra_time_minutes` (`integer`), `deadline_offset_hours` (`integer`), and `extra_attempts` (`integer`).

2. **Hierarchical Extension Resolution on `WorkoutOffering`**:
   The existing `WorkoutOffering#extension_for(user)` method is upgraded to resolve extensions hierarchically (nearest scope wins):
   ```ruby
   def extension_for(user)
     return nil unless user

     # 1. Specific assignment extension (highest precedence)
     specific_ext = student_extensions.find_by(user_id: user.id)
     return specific_ext if specific_ext.present?

     # 2. Workout Series extension (walking up series ancestry if present)
     if workout_series_offering&.workout_series.present?
       series = workout_series_offering.workout_series
       series_ext = StudentExtension.where(
         user_id: user.id,
         course_offering_id: course_offering_id,
         workout_series_id: [series.id] + series.ancestors.pluck(:id),
         workout_offering_id: nil
       ).order(Arel.sql('workout_series_id = ? DESC', series.id)).first
       return series_ext if series_ext.present?
     end

     # 3. Course-Offering-Wide universal accommodation (lowest extension precedence)
     StudentExtension.find_by(
       user_id: user.id,
       course_offering_id: course_offering_id,
       workout_series_id: nil,
       workout_offering_id: nil
     )
   end
   ```

3. **Multi-Scope Factory Method (`StudentExtension.create_or_update!`)**:
   Upgrade `StudentExtension.create_or_update!` to accept any scope object (`WorkoutOffering`, `WorkoutSeries`, or `CourseOffering`):
   ```ruby
   def self.create_or_update!(student, scope, opts)
     attrs = { user: student }
     case scope
     when WorkoutOffering
       attrs[:workout_offering] = scope
       attrs[:course_offering]  = scope.course_offering
       attrs[:workout_series]   = scope.workout_series_offering&.workout_series
     when WorkoutSeriesOffering
       attrs[:workout_series]   = scope.workout_series
       attrs[:course_offering]  = scope.course_offering
       attrs[:workout_offering] = nil
     when WorkoutSeries
       attrs[:workout_series]   = scope
       attrs[:course_offering]  = opts[:course_offering]
       attrs[:workout_offering] = nil
     when CourseOffering
       attrs[:course_offering]  = scope
       attrs[:workout_series]   = nil
       attrs[:workout_offering] = nil
     end

     ext = find_or_initialize_by(attrs)
     ext.assign_extension_options(opts)
     ext.save!
     ext
   end
   ```

4. **Relative Calculation Helpers in `WorkoutOffering`**:
   - `time_limit_for(user)`:
     If the resolved extension has an absolute `time_limit`, use it. If it has a `time_limit_multiplier` (e.g. `1.5`) or `extra_time_minutes`, calculate `(base_time_limit * multiplier) + extra_time`.
   - `hard_deadline_for(user)` & `soft_deadline_for(user)`:
     If the resolved extension has an absolute deadline, use it. If it has a `deadline_offset_hours` (e.g. `+48`), calculate `base_deadline + offset_hours.hours`.
   - `attempts_allowed_for(user)`:
     If the resolved extension has `workout_attempt_limit`, use it. If it has `extra_attempts` (e.g. `+1`), calculate `base_attempts + extra_attempts`.
   - `allowed_ips_for(user)` & `allowed_user_agents_for(user)`:
     If the resolved extension specifies `allowed_ips` or `allowed_user_agents` (e.g. `"any"` or a CIDR), return it; otherwise fall back to the offering's resolved policy.

---

### 3.4 Database Migrations

Following CodeWorkout's convention, migrations use the `fk_type` helper for cross-environment compatibility between `bigint` and `integer` primary keys.

#### Migration 1: Create `workout_series` table
```ruby
class CreateWorkoutSeries < ActiveRecord::Migration[6.0]
  def fk_type(table)
    column = ActiveRecord::Base.connection.columns(table).find { |c| c.name == 'id' }
    column.sql_type.include?('bigint') ? :bigint : :integer
  rescue
    :bigint
  end

  def change
    create_table :workout_series do |t|
      t.references :course, type: fk_type(:courses), null: false, foreign_key: true
      t.references :term, type: fk_type(:terms), null: true, foreign_key: true
      t.references :parent, type: fk_type(:workout_series), null: true,
                            foreign_key: { to_table: :workout_series, on_delete: :cascade }
      
      t.string  :name, null: false
      t.text    :description
      t.integer :position, default: 0, null: false
      t.string  :ancestry, index: true # Materialized path for fast hierarchy traversal

      # Inheritable configuration attributes
      t.integer    :time_limit
      t.integer    :workout_attempt_limit
      t.string     :score_to_keep
      t.bigint     :policy_values, default: 0, null: false
      t.bigint     :policy_mask, default: 0, null: false # 0 = inherit all from parent
      t.text       :allowed_ips
      t.text       :allowed_user_agents
      t.boolean    :published, default: true, null: false # Master series gate (true = open, false = closed draft)

      t.timestamps
    end

    add_index :workout_series, [:course_id, :term_id, :parent_id, :position],
              name: 'idx_series_on_course_term_parent_pos'
  end
end
```

#### Migration 2: Create `workout_series_memberships` table
Links workouts to a series with positional ordering and optional overrides:
```ruby
class CreateWorkoutSeriesMemberships < ActiveRecord::Migration[6.0]
  def fk_type(table)
    column = ActiveRecord::Base.connection.columns(table).find { |c| c.name == 'id' }
    column.sql_type.include?('bigint') ? :bigint : :integer
  rescue
    :bigint
  end

  def change
    create_table :workout_series_memberships do |t|
      t.references :workout_series, type: fk_type(:workout_series), null: false, foreign_key: true
      t.references :workout, type: fk_type(:workouts), null: false, foreign_key: true
      t.integer    :position, default: 0, null: false
      t.text       :override_settings # JSON store for workout-specific overrides within this series

      t.timestamps
    end

    add_index :workout_series_memberships, [:workout_series_id, :workout_id],
              unique: true, name: 'idx_series_memberships_unique'
    add_index :workout_series_memberships, [:workout_series_id, :position],
              name: 'idx_series_memberships_pos'
  end
end
```

#### Migration 3: Create `workout_series_offerings` table
Associates a series tree with specific `course_offerings`:
```ruby
class CreateWorkoutSeriesOfferings < ActiveRecord::Migration[6.0]
  def fk_type(table)
    column = ActiveRecord::Base.connection.columns(table).find { |c| c.name == 'id' }
    column.sql_type.include?('bigint') ? :bigint : :integer
  rescue
    :bigint
  end

  def change
    create_table :workout_series_offerings do |t|
      t.references :workout_series, type: fk_type(:workout_series), null: false, foreign_key: true
      t.references :course_offering, type: fk_type(:course_offerings), null: false, foreign_key: true

      # Schedule and deadline overrides for this section
      t.datetime :opening_date
      t.datetime :soft_deadline
      t.datetime :hard_deadline

      t.timestamps
    end

    add_index :workout_series_offerings, [:workout_series_id, :course_offering_id],
              unique: true, name: 'idx_series_offerings_unique'
  end
end
```

#### Migration 4: Link `workout_offerings` to `workout_series_offerings`
```ruby
class AddWorkoutSeriesOfferingToWorkoutOfferings < ActiveRecord::Migration[6.0]
  def fk_type(table)
    column = ActiveRecord::Base.connection.columns(table).find { |c| c.name == 'id' }
    column.sql_type.include?('bigint') ? :bigint : :integer
  rescue
    :bigint
  end

  def change
    add_reference :workout_offerings, :workout_series_offering,
                  type: fk_type(:workout_series_offerings),
                  null: true,
                  foreign_key: true
  end
end
```

#### Migration 5: Upgrade `student_extensions` for Hierarchical Scoping
Upgrades the existing `student_extensions` table to support course-wide and series-wide scopes alongside relative modifier fields:
```ruby
class UpgradeStudentExtensionsForHierarchicalScoping < ActiveRecord::Migration[6.0]
  def fk_type(table)
    column = ActiveRecord::Base.connection.columns(table).find { |c| c.name == 'id' }
    column.sql_type.include?('bigint') ? :bigint : :integer
  rescue
    :bigint
  end

  def up
    # 1. Allow workout_offering_id to be nullable for series- and course-level accommodations
    change_column_null :student_extensions, :workout_offering_id, true

    # 2. Add course_offering_id reference
    unless column_exists?(:student_extensions, :course_offering_id)
      add_reference :student_extensions, :course_offering,
                    type: fk_type(:course_offerings),
                    null: true,
                    foreign_key: true

      # Backfill course_offering_id from existing workout_offerings
      execute <<-SQL
        UPDATE student_extensions se
        JOIN workout_offerings wo ON se.workout_offering_id = wo.id
        SET se.course_offering_id = wo.course_offering_id
      SQL

      change_column_null :student_extensions, :course_offering_id, false
    end

    # 3. Add workout_series_id reference (null = course-wide accommodation)
    unless column_exists?(:student_extensions, :workout_series_id)
      add_reference :student_extensions, :workout_series,
                    type: fk_type(:workout_series),
                    null: true,
                    foreign_key: true
    end

    # 4. Add relative accommodation fields
    add_column :student_extensions, :time_limit_multiplier, :float, default: 1.0 unless column_exists?(:student_extensions, :time_limit_multiplier)
    add_column :student_extensions, :extra_time_minutes, :integer, default: 0 unless column_exists?(:student_extensions, :extra_time_minutes)
    add_column :student_extensions, :deadline_offset_hours, :integer unless column_exists?(:student_extensions, :deadline_offset_hours)
    add_column :student_extensions, :extra_attempts, :integer unless column_exists?(:student_extensions, :extra_attempts)

    # 5. Compound index for fast hierarchical resolution
    add_index :student_extensions,
              [:user_id, :course_offering_id, :workout_series_id, :workout_offering_id],
              unique: true, name: 'idx_student_ext_hierarchical_scope'
  end

  def down
    remove_index :student_extensions, name: 'idx_student_ext_hierarchical_scope' if index_exists?(:student_extensions, name: 'idx_student_ext_hierarchical_scope')

    remove_column :student_extensions, :extra_attempts if column_exists?(:student_extensions, :extra_attempts)
    remove_column :student_extensions, :deadline_offset_hours if column_exists?(:student_extensions, :deadline_offset_hours)
    remove_column :student_extensions, :extra_time_minutes if column_exists?(:student_extensions, :extra_time_minutes)
    remove_column :student_extensions, :time_limit_multiplier if column_exists?(:student_extensions, :time_limit_multiplier)

    remove_reference :student_extensions, :workout_series if column_exists?(:student_extensions, :workout_series_id)
    remove_reference :student_extensions, :course_offering if column_exists?(:student_extensions, :course_offering_id)

    change_column_null :student_extensions, :workout_offering_id, false
  end
end
```

---

## 4. Hierarchical Tree Architecture & Traversal

### 4.1 Adjacency List with Materialized Path (Ancestry Pattern)

To enable arbitrary nesting ($N$ levels deep) while keeping database reads fast, `WorkoutSeries` uses an **adjacency list with a materialized path column (`ancestry`)**:
- Each root node has `ancestry: nil`.
- Each child node has `ancestry: "#{parent.id}"` or `"#{grandparent.id}/#{parent.id}"`.
- This provides $O(1)$ subtree and ancestor queries without recursive N+1 round trips:
  - Find all ancestors: `WorkoutSeries.where(id: ancestry.split('/'))`
  - Find entire subtree: `WorkoutSeries.where('ancestry = ? OR ancestry LIKE ?', path, "#{path}/%")`

### 4.2 ActiveRecord Model Definition (`app/models/workout_series.rb`)

```ruby
class WorkoutSeries < ApplicationRecord
  #~ Relationships ............................................................
  belongs_to :course, inverse_of: :workout_series
  belongs_to :term, optional: true
  belongs_to :parent, class_name: 'WorkoutSeries', optional: true, inverse_of: :children
  has_many   :children, -> { order(:position) }, class_name: 'WorkoutSeries',
                        foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent

  # Policy getter/setter leveraging the WorkoutPolicy value object
  def workout_policy
    @workout_policy ||= WorkoutPolicy.new(policy_values, policy_mask)
  end

  def workout_policy=(policy)
    if policy.is_a?(WorkoutPolicy)
      self.policy_values = policy.values
      self.policy_mask = policy.mask
      @workout_policy = policy.dup
    end
  end

  has_many :memberships, -> { order(:position) },
           class_name: 'WorkoutSeriesMembership',
           dependent: :destroy,
           inverse_of: :workout_series
  has_many :workouts, through: :memberships

  has_many :series_offerings, class_name: 'WorkoutSeriesOffering',
                              dependent: :destroy,
                              inverse_of: :workout_series
  has_many :course_offerings, through: :series_offerings

  has_many :student_extensions, dependent: :destroy

  #~ Validations ..............................................................
  validates :name, presence: true
  validates :course, presence: true
  validate  :prevent_circular_ancestry

  #~ Callbacks ................................................................
  before_save :sync_ancestry

  #~ Hierarchy Helper Methods .................................................
  def root?
    parent_id.nil?
  end

  def root
    root? ? self : WorkoutSeries.find(ancestry_ids.first)
  end

  def ancestry_ids
    ancestry.to_s.split('/').map(&:to_i)
  end

  def ancestors
    return [] if root?
    WorkoutSeries.where(id: ancestry_ids).order(:id)
  end

  def path
    ancestors + [self]
  end

  def descendants
    path_str = ancestry.present? ? "#{ancestry}/#{id}" : id.to_s
    WorkoutSeries.where('ancestry = ? OR ancestry LIKE ?', path_str, "#{path_str}/%")
  end

  def all_workouts
    Workout.where(id: all_membership_workout_ids)
  end

  def all_membership_workout_ids
    series_ids = [id] + descendants.pluck(:id)
    WorkoutSeriesMembership.where(workout_series_id: series_ids).pluck(:workout_id).uniq
  end

  private

  def sync_ancestry
    self.ancestry = parent.present? ? "#{parent.ancestry.presence && "#{parent.ancestry}/"}#{parent.id}" : nil
  end

  def prevent_circular_ancestry
    if parent_id.present? && (parent_id == id || ancestors.map(&:id).include?(id))
      errors.add(:parent_id, 'cannot create a circular hierarchy reference.')
    end
  end
end
```

---

## 5. Cascading Settings & Unified Extensions Engine

### 5.1 Settings Inheritance Flowchart

When calculating assessment parameters (e.g., `time_limit`, `allowed_ips`, or `allowed_user_agents`) for a specific student attempting a workout:

```
+-------------------------------------------------------------------------+
| 1. StudentExtension (Workout-Specific Scope)                            |
|    - Explicit override for this exact (user, workout_offering)          |
+------------------------------------+------------------------------------+
                                     | if nil / inherit
                                     v
+-------------------------------------------------------------------------+
| 2. StudentExtension (Series-Level Scope)                                |
|    - Accommodation for this student on this specific Workout Series     |
+------------------------------------+------------------------------------+
                                     | if nil / inherit
                                     v
+-------------------------------------------------------------------------+
| 3. StudentExtension (Course-Offering-Wide Scope)                        |
|    - Universal accommodation for this student (e.g. 1.5x time, ips: any)|
+------------------------------------+------------------------------------+
                                     | applies base multiplier/override to:
                                     v
+-------------------------------------------------------------------------+
| 4. WorkoutOffering Explicit Configuration                               |
|    - Section-specific setting set directly on WorkoutOffering           |
+------------------------------------+------------------------------------+
                                     | if nil / inherit
                                     v
+-------------------------------------------------------------------------+
| 5. WorkoutSeriesMembership Override                                     |
|    - Workout-specific override configured within this series            |
+------------------------------------+------------------------------------+
                                     | if nil / inherit
                                     v
+-------------------------------------------------------------------------+
| 6. Immediate Parent WorkoutSeries                                       |
|    - WorkoutSeries#send(attr)                                           |
+------------------------------------+------------------------------------+
                                     | if nil / inherit
                                     v
+-------------------------------------------------------------------------+
| 7. Ancestor Series Traversal (Bottom-Up toward Root)                    |
|    - Walks parent -> grandparent -> root series                         |
+------------------------------------+------------------------------------+
                                     | if nil / inherit
                                     v
+-------------------------------------------------------------------------+
| 8. CourseOffering (Top-Level Root Series Default)                       |
|    - Course-wide default policies and restrictions                      |
+------------------------------------+------------------------------------+
                                     | if nil / inherit
                                     v
+-------------------------------------------------------------------------+
| 9. Global System Default Baseline                                       |
+-------------------------------------------------------------------------+
```

---

### 5.2 Inheritance & Extension Resolver Implementation

```ruby
class WorkoutSeriesSettingResolver
  CONFIG_ATTRIBUTES = %i[
    time_limit
    workout_attempt_limit
    score_to_keep
    workout_policy
    allowed_ips
    allowed_user_agents
    published
  ].freeze

  def initialize(workout_offering, user = nil)
    @workout_offering = workout_offering
    @workout = workout_offering.workout
    @course_offering = workout_offering.course_offering
    @series_offering = workout_offering.workout_series_offering
    @series = @series_offering&.workout_series
    @user = user
  end

  # Resolves time limit factoring in student extensions (absolute or multipliers)
  def effective_time_limit
    ext = effective_student_extension
    if ext&.time_limit.present?
      return ext.time_limit
    end

    base_limit = resolve_base_setting(:time_limit)
    return nil if base_limit.blank? || base_limit <= 0

    if ext
      mult = ext.time_limit_multiplier.presence || 1.0
      extra = ext.extra_time_minutes.presence || 0
      ((base_limit * mult) + extra).round
    else
      base_limit
    end
  end

  # Resolves allowed IPs with student extension/accommodation bypass
  def effective_allowed_ips
    ext = effective_student_extension
    return ext.allowed_ips if ext&.allowed_ips.present?

    resolve_base_setting(:allowed_ips)
  end

  # Resolves allowed user agents with assistive technology bypass
  def effective_allowed_user_agents
    ext = effective_student_extension
    return ext.allowed_user_agents if ext&.allowed_user_agents.present?

    resolve_base_setting(:allowed_user_agents)
  end

  # Resolves attempt limits factoring in extensions and extra attempts
  def effective_attempt_limit
    ext = effective_student_extension
    if ext&.workout_attempt_limit.present?
      return ext.workout_attempt_limit
    end

    base_limit = resolve_base_setting(:workout_attempt_limit) || 1
    if ext&.extra_attempts.present?
      base_limit + ext.extra_attempts
    else
      base_limit
    end
  end

  # Resolves base setting up the series hierarchy and course offering
  def resolve_base_setting(attr_name)
    # 1. Explicit WorkoutOffering setting
    val = @workout_offering.read_attribute(attr_name)
    return val unless val.nil?

    # 2. Membership override within series
    if @series.present?
      membership = @series.memberships.find_by(workout: @workout)
      if membership&.override_settings.present?
        val = membership.parsed_overrides[attr_name.to_s]
        return val unless val.nil?
      end

      # 3. Series and ancestor series traversal
      ([@series] + @series.ancestors.reverse).each do |node|
        val = node.read_attribute(attr_name)
        return val unless val.nil?
      end
    end

    # 4. CourseOffering level defaults (treating CourseOffering as top-level series)
    if @course_offering.respond_to?("default_#{attr_name}")
      val = @course_offering.send("default_#{attr_name}")
      return val unless val.nil?
    end

    # 5. Global fallback default
    default_for(attr_name)
  end

  # Resolves student extension hierarchically (Assignment -> Series -> CourseOffering)
  def effective_student_extension
    return nil unless @user && @course_offering

    @effective_student_extension ||= begin
      # 1. Assignment-specific extension
      specific_ext = StudentExtension.find_by(
        user: @user,
        workout_offering: @workout_offering
      )
      return specific_ext if specific_ext.present?

      # 2. Series-specific extension (check series then ancestors)
      if @series.present?
        series_scope_ids = [@series.id] + @series.ancestors.pluck(:id)
        series_ext = StudentExtension.where(
          user: @user,
          course_offering: @course_offering,
          workout_series_id: series_scope_ids,
          workout_offering_id: nil
        ).order(Arel.sql("FIELD(workout_series_id, #{series_scope_ids.join(',')})")).first
        return series_ext if series_ext.present?
      end

      # 3. Course-offering-wide universal extension/accommodation
      StudentExtension.find_by(
        user: @user,
        course_offering: @course_offering,
        workout_series_id: nil,
        workout_offering_id: nil
      )
    end
  end

  private

  def default_for(attr_name)
    case attr_name
    when :score_to_keep then 'highest'
    when :workout_attempt_limit then 1
    when :published then true
    else nil
    end
  end
end
```

---

### 5.3 Dual-Bitmask Workout Policy Architecture & Inheritance

#### 5.3.1 Motivation & Elimination of the Legacy Table
Originally, workout policies were stored in a separate `workout_policies` table because there were only a handful of shared presets. Over time, instructors required workout-specific customizations that diverged across terms. A previous migration (`EnsureWorkoutPoliciesAreNotSharedBetweenWorkouts`) had to clone rows to break accidental cross-workout sharing.

In the Workout Series hierarchy, managing a separate `workout_policies` table creates heavy friction:
- Every series or offering that overrides even 1 checkbox would spawn a separate 12-column row containing 11 `NULL`s.
- Cloning workouts or series between terms requires deep-cloning policy records and managing foreign keys.
- Accidental cross-term or cross-workout sharing bugs can resurface.

To solve this permanently, the design replaces the `workout_policies` table with a **Dual-Bitmask Representation** stored directly on `course_offerings`, `workout_series`, and `workout_offerings`:
1. **`policy_values: bigint`**: Stores the boolean value for each flag (`1` = true, `0` = false).
2. **`policy_mask: bigint`**: Records whether each setting is explicitly overridden at this level (`1` = overridden/configured, `0` = inherit from parent).

#### 5.3.2 Bit Layout (12 Policy Flags)
The 12 boolean settings are mapped to fixed, immutable powers of 2:

| Bit Position | Value | Flag Attribute | Default | Description |
| :---: | :---: | :--- | :---: | :--- |
| **0** | `1` | `hide_compilation_feedback_before_finish` | `false` | Hide compile-time errors while student is working. |
| **1** | `2` | `hide_feedback_before_finish` | `false` | Hide test runner execution results until finished. |
| **2** | `4` | `hide_feedback_in_review_before_close` | `false` | Hide test results in review before deadline. |
| **3** | `8` | `hide_score_before_finish` | `false` | Hide earned points during active attempt. |
| **4** | `16` | `hide_score_in_review_before_close` | `false` | Hide score during review before workout close. |
| **5** | `32` | `hide_thumbnails_before_start` | `false` | Hide exercise list on workout landing page. |
| **6** | `64` | `hide_thumbnails_in_review_before_close` | `false` | Hide exercise thumbnails during review. |
| **7** | `128` | `invisible_before_review` | `false` | Hide workout from course page until review. |
| **8** | `256` | `no_faq` | `false` | Disable FAQ links. |
| **9** | `512` | `no_hints` | `false` | Suppress hints on exercises. |
| **10** | `1024` | `no_review_before_close` | `false` | Suppress review view until closed/deadline. |
| **11** | `2048` | `see_answers` | `true` | Allow students to view their submitted code. |

- **`ALL_FLAGS_MASK`**: `4095` (`(1 << 12) - 1`, 0x0FFF)
- **`SYSTEM_DEFAULT_VALUES`**: `2048` (`1 << 11`, only `see_answers` is `true`)
- **`SYSTEM_DEFAULT_MASK`**: `4095` (all 12 flags explicitly defined at the baseline)

#### 5.3.3 Tri-State Inheritance & Bitwise Folding
At any level of the tree (`CourseOffering` $\rightarrow$ `WorkoutSeries` ancestors $\rightarrow$ `WorkoutSeries` $\rightarrow$ `WorkoutOffering`), a setting has three states:
- `mask bit = 0`: **Inherit**. Defer to parent level.
- `mask bit = 1, values bit = 1`: **Explicit True**. Override parent setting to `true`.
- `mask bit = 1, values bit = 0`: **Explicit False**. Override parent setting to `false`.

Inheritance is resolved via single-cycle bitwise operations:
```ruby
# Merging a child node's overrides onto an accumulated parent policy:
effective_values = (child_values & child_mask) | (parent_values & ~child_mask)
effective_mask   = parent_mask | child_mask
```

#### 5.3.4 Value Object Abstraction (`WorkoutPolicy`)
The database table `workout_policies` is dropped, but the Ruby class `WorkoutPolicy` is preserved as a lightweight, non-ActiveRecord **Value Object**:
- **Backward-Compatible API**: Implements all 12 attribute readers (`see_answers`), setters (`see_answers=`), predicates (`see_answers?`), `#update(hash)`, `#dup`, and `#to_h`.
- **Zero View Adjustments**: Existing views (e.g., `@workout_offering.workout_policy.no_review_before_close`) continue to work seamlessly without modification.
- **Direct offering sync**: Mutating `@workout_offering.workout_policy` automatically syncs `policy_values` and `policy_mask` on `WorkoutOffering` before save.
- **Instant Duplication**: Cloning an offering or series across terms copies just two integers (`new.policy_values = old.policy_values; new.policy_mask = old.policy_mask`), executing instantaneously with zero relational table cloning overhead.

---

### 5.4 Workout Series Publishing: The Gated Visibility Pattern & Cascading Bulk Actions

Managing the visibility of assignments across an academic semester presents two essential requirements that can easily conflict:
1. **Single-Action Publishing**: The ability for teaching staff to stage an entire unit, module, or lab series privately and publish it in one click when the semester reaches that point.
2. **Selective Hold-Backs (Drafts)**: The ability to keep a specific assignment (such as a surprise pop quiz or an upcoming exam) hidden as an unpublished draft, even when the surrounding parent series is already live.

To address both needs without mutating hundreds of database rows or forcing instructors to manually toggle every individual workout, CodeWorkout implements **Strategy 1: The Two-Level Module Gate Pattern** (the architectural standard used by Canvas and modern LMSs), augmented with **Strategy 2: Cascading Bulk Action UI Controls**.

#### 5.4.1 The Two-Level Module Gate Architecture (Strategy 1)
Both `WorkoutSeries` and `WorkoutOffering` maintain a dedicated `published: boolean` database column:
- **`WorkoutSeries#published` (Master Gate)**: Controls whether the series container as a whole is open to students. When `false`, the entire container and all its contents are hidden from student view regardless of member settings.
- **`WorkoutOffering#published` (Item Readiness)**: Controls whether the individual workout offering is finalized and approved for students.

**Compound Visibility Rule**:
An individual workout offering is visible to students on their course page if and only if **both** the workout offering is published AND its parent series (and all ancestor series up to the root) is published:

$$\text{Visible to Students} \iff \text{workout\_offering.published} \land (\text{series.nil?} \lor \text{series.published?})$$

```ruby
# In WorkoutOffering:
scope :visible_to_students, -> {
  left_outer_joins(:workout_series_offering => :workout_series)
    .where(published: true)
    .where('workout_series.id IS NULL OR workout_series.published = TRUE')
    .where('((workout_offerings.policy_mask & 128) = 0) OR ((workout_offerings.policy_values & 128) = 0)')
    .where('opening_date IS NULL OR opening_date <= ?', Time.zone.now)
}
```

#### 5.4.2 State Matrix: Series Master Gate vs. Workout Item State

| Series Gate (`series.published`) | Workout State (`offering.published`) | Visible to Students? | Pedagogical & Workflow Meaning |
| :---: | :---: | :---: | :--- |
| **`false`** (Closed Gate) | `true` (Ready) | **NO** | **Staged in Draft Series**: The assignment is ready and pre-published, but kept private because the entire series module is still under construction. |
| **`false`** (Closed Gate) | `false` (Draft) | **NO** | **Unpublished Draft**: Neither the series nor the workout is ready. |
| **`true`** (Open Gate) | **`true`** (Ready) | **YES** | **Live & Visible**: Both gate and assignment are open. Available to students on the course dashboard. |
| **`true`** (Open Gate) | **`false`** (Draft) | **NO** | **Selective Hold-Back**: The series is live, but this specific workout is deliberately withheld as an instructor draft. |

#### 5.4.3 UI Workflow: Cascading Bulk Action Support (Strategy 2)
To provide maximum flexibility and speed, the Series Management UI introduces **publishing action modals** that give instructors the choice between Gate-Only and Cascading Bulk actions:

1. **Publishing a Series**:
   When an instructor clicks the "Publish" toggle on a `WorkoutSeries`, a confirmation dialog appears:
   - **Option A: "Publish Series Gate Only" (Default / Recommended)**:
     - Sets `workout_series.published = true`.
     - Opens the master gate: all member workouts that were pre-staged with `published: true` instantly become live in **one single action**.
     - Any workouts intentionally marked `published: false` remain safely hidden drafts.
   - **Option B: "Publish Series and All Member Workouts" (Cascading Bulk Action)**:
     - Opens the series gate (`workout_series.update!(published: true)`).
     - Executes an atomic SQL batch update setting `published = true` across all descendant sub-series and member offerings in that branch:
       ```ruby
       WorkoutSeries.transaction do
         @series.update!(published: true)
         @series.descendants.update_all(published: true)
         @series.all_workout_offerings.update_all(published: true)
       end
       ```
2. **Unpublishing a Series**:
   - **Option A: "Unpublish Series Gate Only" (Default)**:
     - Closes the series gate (`published: false`), instantly hiding the entire branch from students.
     - Preserves each individual workout's `published` state, ensuring that re-opening the gate in the future restores the exact prior visibility without reconfiguration.
   - **Option B: "Unpublish Series and All Member Workouts" (Cascading Bulk Unpublish)**:
     - Closes the series gate and recursively resets every descendant offering to `published: false`.

#### 5.4.4 Visual Status Badges in the Instructor Dashboard
In the series hierarchy manager, each workout offering displays an unambiguous status indicator:
- 🟢 **Live**: Series gate is open, offering is published (`published: true`).
- ⚪ **Staged (Gated)**: Offering is ready (`published: true`), but waiting on parent series gate (`series.published: false`).
- 🟡 **Withheld Draft**: Series gate is open, but this workout is specifically held back (`published: false`).
- ⚫ **Full Draft**: Both series gate and workout are unpublished.

---

## 6. Multi-Section Semester Management for Teaching Teams

### 6.1 Unified Multi-Offering Coordination

In a university course:
1. **Teaching Teams Author the Hierarchy Once**: The instructors define the series tree for the `Course` and `Term` (e.g., CS 1114, Fall 2026):
   - **Homework Series** (HW 1, HW 2, ..., HW 10)
   - **In-Class Quiz Series** (Quiz 1, Quiz 2, ..., Quiz 6)
   - **Examination Series** (Midterm 1, Midterm 2, Final Exam)
2. **Configure Student Extensions / Accommodations Once**:
   - Students with registered accommodations have their `StudentExtension` defined once at the `CourseOffering` level (e.g., Jane Doe: 1.5x time on all quizzes and exams).
   - All workouts added to the quiz or exam series automatically inherit Jane Doe's 1.5x time without instructors creating 30 individual records.
3. **Sections Inherit Dates Relative to Section Schedules**:
   - Section 001 meets MWF at 10:10 AM.
   - Section 002 meets TR at 2:00 PM.
   - A series offering can define relative timing (e.g., `due: class_end + 0 minutes` or relative day offsets).
4. **Instantiating WorkoutOfferings**:
   - A series management service iterates through all sections in the semester and automatically synchronizes the corresponding `WorkoutOffering` records.

---

### 6.2 Declarative YAML Representation

Instructors can version-control and configure the entire series tree, section schedules, and student accommodations in a clean YAML specification:

```yaml
series: "Assessments"
description: "All graded quizzes and examinations for Fall 2026"
settings:
  workout_policy:
    hide_feedback_before_finish: true
    invisible_before_review: true
    no_review_before_close: true
  allowed_user_agents: ["LockDown Browser", "SEB"]
  allowed_ips: "198.82.0.0/16"
  score_to_keep: "highest"

sub_series:
  - series: "Weekly Quizzes"
    settings:
      time_limit: 30
      workout_attempt_limit: 2
    workouts:
      - name: "Quiz 1: Java Basics"
        exercises: [101, 102, 103, 104]
      - name: "Quiz 2: Control Flow"
        exercises: [105, 106, 107, 108]

  - series: "Midterm Exams"
    settings:
      time_limit: 75
      workout_attempt_limit: 1
    workouts:
      - name: "Midterm 1: Syntax & Methods"
        exercises: [201, 202, 203, 204, 205]

# Course-Offering-Wide and Series-Wide Student Extensions / Accommodations
extensions:
  - student: "asmith@example.edu"
    time_limit_multiplier: 1.5     # 1.5x time on all timed workouts in course
    allowed_ips: "any"             # Can take from accommodation testing center
  - student: "jdoe@example.edu"
    series: "Weekly Quizzes"       # Scoped specifically to Quizzes
    time_limit_multiplier: 2.0     # Double time
    allowed_user_agents: "any"     # Screen reader assistive tool bypass

sections:
  - section: "CS 1114 (Fall 2026, Section 001)"
    schedule:
      "Quiz 1: Java Basics":
        from: "2026-09-15 10:10 AM"
        due:  "2026-09-15 10:40 AM"
        until: "2026-09-15 10:45 AM"
  - section: "CS 1114 (Fall 2026, Section 002)"
    schedule:
      "Quiz 1: Java Basics":
        from: "2026-09-15 02:00 PM"
        due:  "2026-09-15 02:30 PM"
        until: "2026-09-15 02:35 PM"
```

---

## 7. User Interface & Workflow Integration

### 7.1 Instructor Experience

1. **Course Offerings "Workout Series" Manager**:
   - A visual, collapsible tree view (`<tree-view>`) in the instructor dashboard.
   - Teachers can drag-and-drop to reorder workouts within a series, or move sub-series into parent series.
   - **Inheritance Badges**: Each node displays inherited vs. overridden settings with visual badges (e.g., `Time Limit: 30m [Inherited from Weekly Quizzes]`).
2. **Unified Extensions & Accommodations Manager**:
   - Dedicated table under Course Offering $\rightarrow$ *"Extensions & Accommodations"*:
     - View all enrolled students with active accommodations and one-off extensions.
     - Add a student extension once (e.g. "Jane Doe - 1.5x time multiplier, IP unrestricted").
     - Scope selector: "Whole Course", a specific "Workout Series", or an individual "Workout".
3. **Bulk Actions**:
   - *"Apply to All Sections in Fall 2026"*: Synchronize hierarchy modifications and policy settings across all managed course offerings for the semester.
   - *"Emergency Schedule Shift"*: Shift all opening dates and deadlines in this series branch by $+X$ hours/days across all managed sections.
4. **Series Gate & Publishing Controls**:
   - One-click toggle on any series node to open or close the **master series gate**.
   - **Publishing Modal**: Prompts the instructor with the option to:
     - **Open Gate Only** (instant single action: member workouts marked `published: true` go live; drafts stay withheld).
     - **Cascade Publish** (executes bulk `update_all(published: true)` down the branch).
   - **Visual Gate Indicators**: Clear status pills next to every workout offering (`Live`, `Staged / Gated`, `Withheld Draft`, `Unpublished`).

### 7.2 Student Experience

1. **Structured Workout Series Accordion**:
   - Instead of a flat list of 50 unorganized workouts on the course page, students see an organized accordion:
     - **📁 Series: Module 1 Fundamentals** *(Completed 3/3)*
     - **📁 Series: Weekly Quizzes** *(In Progress 1/4)*
       - **Quiz 1: Java Basics** (Score: 100%, 2 Attempts)
       - **Quiz 2: Control Flow** (Available until Oct 20)
2. **Contextual Breadcrumbs & Accommodated Timers**:
   - Breadcrumb trail reflects the series path:
     `CS 1114 > Fall 2026 > Assessments > Weekly Quizzes > Quiz 2`.
   - If a student has a 1.5x accommodation, the countdown timer displays their accommodated time limit automatically without requiring instructor intervention per quiz.

---

## 8. Summary of Benefits & Implementation Checklist

### 8.1 Key Architectural Benefits

| Capability | Without Series (Current) | With Hierarchical Workout Series & Scoped Extensions |
| :--- | :--- | :--- |
| **Settings Configuration** | Configured individually on every workout offering ($W \times S$ configurations). | Configured once at parent series or course offering; cascades automatically. |
| **Student Accommodations** | Must create $N$ individual `StudentExtension` records per student ($S \times W$ entries). | Configured **once** per student using unified `StudentExtension` at Course Offering or Series level. |
| **Data Model Unification** | Risk of split `StudentExtension` and `StudentAccommodation` tables. | Single unified `StudentExtension` table with scoped foreign keys and relative modifiers. |
| **Top-Level Root Container** | No unifying concept between course sections and individual assignments. | `CourseOffering` functions naturally as the top-level series offering scope. |
| **Multi-Section Consistency** | Prone to drift between section settings; manual verification needed. | Single source of truth across all sections in the semester. |
| **Organization** | Flat list of workouts; difficult for students and staff to navigate. | Clean, arbitrarily deep tree structure matching course syllabus. |
| **Emergency Adjustments** | Must edit 20 separate workout offerings one by one. | Shift or edit parent series; updates entire branch across all sections instantly. |

---

### 8.2 File-by-File Implementation Checklist

| Component | Files to Create / Modify | Responsibilities |
| :--- | :--- | :--- |
| **Database Migrations** | `db/migrate/YYYYMMDD_create_workout_series.rb`<br>`db/migrate/YYYYMMDD_create_workout_series_memberships.rb`<br>`db/migrate/YYYYMMDD_create_workout_series_offerings.rb`<br>`db/migrate/YYYYMMDD_upgrade_student_extensions_for_hierarchical_scoping.rb`<br>`db/migrate/YYYYMMDD_add_series_offering_to_workout_offerings.rb` | Create tables with `fk_type` foreign keys, indices, materialized ancestry path, and upgrade `student_extensions` schema. |
| **Models** | `app/models/workout_series.rb`<br>`app/models/workout_series_membership.rb`<br>`app/models/workout_series_offering.rb`<br>`app/models/student_extension.rb`<br>`app/models/course_offering.rb`<br>`app/models/workout_offering.rb`<br>`app/models/workout.rb` | Implement hierarchy traversal, ancestry sync, cascading resolver, unified `StudentExtension` scopes, and associations. |
| **Services** | `app/services/workout_series_setting_resolver.rb`<br>`app/services/workout_series_offering_syncer.rb` | Handle cascading inheritance resolution, hierarchical student extension calculations, and multi-section sync. |
| **Controllers** | `app/controllers/workout_series_controller.rb`<br>`app/controllers/student_extensions_controller.rb`<br>`app/controllers/course_offerings_controller.rb` | CRUD operations for series tree, unified extension/accommodation management, and bulk branch operations. |
| **Views & Helpers** | `app/views/workout_series/_tree_node.html.haml`<br>`app/views/student_extensions/_form.html.haml`<br>`app/views/courses/_tab_workouts.html.haml`<br>`app/views/workouts/_form.html.haml` | Accordion/tree view for students; drag-and-drop hierarchy editor and extensions table for instructors. |
| **Automated Specs** | `spec/models/workout_series_spec.rb`<br>`spec/models/student_extension_spec.rb`<br>`spec/services/workout_series_setting_resolver_spec.rb`<br>`spec/controllers/workout_series_controller_spec.rb` | Unit and integration tests for hierarchy cycles, cascading settings, student extension multipliers, and multi-section sync. |
