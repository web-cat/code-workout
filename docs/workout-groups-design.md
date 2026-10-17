# Hierarchical Workout Grouping: Architectural Design & Naming Analysis

## 1. Naming Analysis: Selecting the Ideal Term

### 1.1 Criteria & Constraints

When naming a grouping mechanism for workouts in CodeWorkout:
1. **Avoid Human-Centric Terms**: Names like `team`, `squad`, `crew`, or `cohort` suggest student groups, study partners, or instructor teams, creating immediate conceptual confusion with user groups and course rosters.
2. **Avoid Overly Generic Abstract Terms**: Names like `cluster`, `group`, `set`, `collection`, or `pack` are bland, computer-science-heavy, or already overloaded (e.g., Ruby's `Set`, database `UserGroup`, CodeWorkout's `ExerciseCollection`).
3. **Avoid Ill-Fitting or Eccentric Metaphors**: Names like `gaggle`, `batch`, `bundle`, or `flock` either sound whimsical or suggest batch background jobs.
4. **Support Arbitrary Hierarchical Nesting**: The term must feel natural when nested recursively (e.g., a "parent ____" containing "sub-____s").
5. **Resonate with CodeWorkout’s Metaphor & Higher Education**: The name should naturally bridge CodeWorkout's **fitness/gym metaphor** and **academic course structure**.

---

### 1.2 Evaluation of Candidate Names

| Candidate | Domain Origin | Strengths | Limitations | Rating |
| :--- | :--- | :--- | :--- | :--- |
| **Routine**<br>*(or Workout Routine)* | **Fitness / Gym** | Directly reinforces CodeWorkout's core metaphor. In athletics, a *routine* is an orchestrated set of workouts/drills performed toward a single training objective (e.g., *"Leg Day Routine"*, *"Core Conditioning Routine"*). Easily nests: a *"Full Body Routine"* contains a *"Warmup Routine"*, *"Strength Routine"*, and *"Cooldown Routine"*. | Less conventional in traditional LMS terminology, though instantly understood in CodeWorkout. | **Top Pick (Metaphor)** ⭐⭐⭐⭐⭐ |
| **Suite**<br>*(or Workout Suite)* | **Architecture / Software** | Dignified, professional, and precise. Like a *test suite* or *application suite*, it denotes a curated, harmonious collection of components grouped for a unified purpose. Sub-suites nest seamlessly (`Suite` -> `Sub-suite`). | Lacks the fitness theme, but sounds exceptionally clean and structured. | **Top Pick (Architectural)** ⭐⭐⭐⭐⭐ |
| **Module** | **Pedagogical / LMS** | Universal standard across higher education and modern LMSs (Canvas, edX, Coursera). Instructors instantly recognize that a "Module" contains sub-modules, assignments, and quizzes. Zero learning curve for teaching teams. | Generic across LMSs; does not lean into the gym metaphor. | **Top Pick (Academic)** ⭐⭐⭐⭐⭐ |
| **Series**<br>*(or Workout Series)* | **Pedagogical / General** | Exceptionally natural phrasing in course syllabi: *"Lab Series"*, *"Quiz Series"*, *"Recursion Practice Series"*. | Recursive nesting can sound slightly awkward (*"sub-series within a series"*). | **Strong Alternative** ⭐⭐⭐⭐ |
| **Circuit** | **Fitness / Gym** | Great gym metaphor (circuit training). | Implies a sequential loop where stations must be completed in continuous rotational order, which does not match all academic assignments. | **Moderate** ⭐⭐⭐ |
| **Track** | **Curriculum / Pathway** | Connotes a progression pathway (e.g., *"Advanced Track"*). | Better suited for entire degree concentrations or learning paths than hierarchical assignment folders. | **Moderate** ⭐⭐⭐ |
| **Block**<br>*(Training Block)* | **Fitness Periodization** | Used in athletic training blocks (mesocycles). | Heavily overloaded in Ruby (`do ... end` blocks) and programming syntax. | **Poor** ⭐⭐ |

---

### 1.3 Recommended Decisions

Depending on the primary tone the project wishes to convey:

1. **Best Overall (Gym Metaphor Alignment)**: **`Routine`** (e.g., `WorkoutRoutine`)
   - *Example hierarchy*:
     - **Midterm 1 Preparation Routine**
       - **Fundamentals Routine**: Variables, Conditionals
       - **Loop Mastery Routine**: While Loops, For-Each Loops
   - *Rationale*: It extends the gym theme ("Workouts make up a Routine; Exercises make up a Workout").

2. **Best Architectural / Non-Gym Alternative**: **`Suite`** (e.g., `WorkoutSuite`)
   - *Example hierarchy*:
     - **Laboratory Suite** -> **Week 3 Lab Suite** -> **Part A / Part B**
   - *Rationale*: Professional, clean, and unambiguous.

3. **Best LMS / Faculty-Facing Alternative**: **`Module`** (e.g., `WorkoutModule`)
   - *Example hierarchy*:
     - **Module 1: Object-Oriented Design** -> **Sub-module 1.2: Inheritance**
   - *Rationale*: Direct 1:1 conceptual match with Canvas LMS Modules.

*(For the remainder of this architectural specification, we use **`WorkoutRoutine`** as the primary entity name, with the note that the exact name token can be configured as `WorkoutSuite` or `WorkoutModule` without altering the underlying architecture).*

---

## 2. Problem Statement & Semester-Long Multi-Section Context

### 2.1 The Multi-Offering Problem in Multi-Section Courses

In university courses (such as introductory programming with 500–2,000 students):
- A single **`Course`** (e.g., CS 1114) in a single **`Term`** (e.g., Fall 2026) is taught across **multiple `CourseOffering`s** (Section 001, Section 002, Section 003, Honors Section 091).
- A unified **teaching team** (lead professor, co-instructors, and head teaching assistants in the course's `UserGroup`) coordinates all sections.
- The instructors assign dozens of workouts: weekly labs, daily practice drills, timed in-class quizzes, and major exams.
- Currently, settings (time limits, LockDown Browser requirements, IP restrictions, attempt policies, and deadlines) must be configured **on every single `WorkoutOffering` individually**, or repeated section-by-section in YAML strings.

### 2.2 Requirements for the Solution

1. **Hierarchical Tree Structure**: Routines can be nested arbitrarily deep ($N$ levels: Root Routine $\rightarrow$ Child Routines $\rightarrow$ Workouts).
2. **Cascading Settings & Inheritance**: Settings defined at a parent routine automatically cascade down to all sub-routines and member workouts, unless an explicit override is provided.
3. **Shared Across Course Offerings in a Semester**: The hierarchy is authored **once** for the course/term by the teaching staff, and then applied across all section offerings in that semester.
4. **Section-Specific Schedule Offsets**: Sections meeting on different days/times (e.g., Section 001 on Mon/Wed vs. Section 002 on Tue/Thu) can derive their deadlines from section meeting templates while sharing the identical routine structure and policy settings.
5. **Bulk Administrative Operations**: Instructors can publish, unpublish, close, or shift deadlines for an entire routine branch with a single action (e.g., emergency snow-day date adjustment).

---

## 3. Domain Model & Database Schema

### 3.1 Entity Relationship Diagram

```
+--------------------------------------------------------------------------+
|                                  Course                                  |
+------------------------------------+-------------------------------------+
                                     | 1
                                     |
                                     | has_many :workout_routines
                                     |
                                     v *
+------------------------------------+-------------------------------------+
|                              WorkoutRoutine                              |
|  - id: bigint                                                            |
|  - course_id: bigint                                                     |
|  - term_id: bigint (optional; nil = reusable course-wide template)       |
|  - parent_id: bigint (self-referential foreign key)                      |
|  - name: string                                                          |
|  - description: text                                                     |
|  - position: integer (ordering among siblings)                           |
|  - time_limit: integer (inherited setting)                               |
|  - workout_attempt_limit: integer (inherited setting)                    |
|  - score_to_keep: string (inherited setting)                             |
|  - workout_policy_id: bigint (inherited policy)                          |
|  - allowed_ips: text (inherited IP restrictions)                         |
|  - allowed_user_agents: text (inherited browser restrictions)            |
|  - published: boolean (inherited visibility)                             |
+--------------------+-------------------------------+---------------------+
                     | 1                             | 1
                     | has_many                      | has_many
                     v *                             v *
+--------------------+------------------+   +--------+---------------------+
|        WorkoutRoutineMembership       |   |       WorkoutRoutineOffering |
|  - workout_routine_id: bigint         |   |  - workout_routine_id: bigint|
|  - workout_id: bigint                 |   |  - course_offering_id: bigint|
|  - position: integer                  |   |  - opening_offset: integer   |
|  - override_settings: json / text     |   |  - soft_deadline_offset: int |
+--------------------+------------------+   |  - hard_deadline_offset: int |
                     |                      +------------------------------+
                     | references
                     v
+--------------------+------------------+
|               Workout                |
+--------------------------------------+
```

---

### 3.2 Database Migrations

Following CodeWorkout's convention, migrations use the `fk_type` helper for cross-environment compatibility between `bigint` and `integer` primary keys.

#### Migration 1: Create `workout_routines` table
```ruby
class CreateWorkoutRoutines < ActiveRecord::Migration[6.0]
  def fk_type(table)
    column = ActiveRecord::Base.connection.columns(table).find { |c| c.name == 'id' }
    column.sql_type.include?('bigint') ? :bigint : :integer
  rescue
    :bigint
  end

  def change
    create_table :workout_routines do |t|
      t.references :course, type: fk_type(:courses), null: false, foreign_key: true
      t.references :term, type: fk_type(:terms), null: true, foreign_key: true
      t.references :parent, type: fk_type(:workout_routines), null: true,
                            foreign_key: { to_table: :workout_routines, on_delete: :cascade }
      
      t.string  :name, null: false
      t.text    :description
      t.integer :position, default: 0, null: false
      t.string  :ancestry, index: true # Materialized path for high-performance hierarchy traversal

      # Inheritable configuration attributes
      t.integer    :time_limit
      t.integer    :workout_attempt_limit
      t.string     :score_to_keep
      t.references :workout_policy, type: fk_type(:workout_policies), null: true, foreign_key: true
      t.text       :allowed_ips
      t.text       :allowed_user_agents
      t.boolean    :published, default: nil # nil = inherit, true/false = explicit

      t.timestamps
    end

    add_index :workout_routines, [:course_id, :term_id, :parent_id, :position],
              name: 'idx_routines_on_course_term_parent_pos'
  end
end
```

#### Migration 2: Create `workout_routine_memberships` table
Links workouts to routines with positional ordering and optional node-level overrides:
```ruby
class CreateWorkoutRoutineMemberships < ActiveRecord::Migration[6.0]
  def fk_type(table)
    column = ActiveRecord::Base.connection.columns(table).find { |c| c.name == 'id' }
    column.sql_type.include?('bigint') ? :bigint : :integer
  rescue
    :bigint
  end

  def change
    create_table :workout_routine_memberships do |t|
      t.references :workout_routine, type: fk_type(:workout_routines), null: false, foreign_key: true
      t.references :workout, type: fk_type(:workouts), null: false, foreign_key: true
      t.integer    :position, default: 0, null: false
      t.text       :override_settings # JSON store for workout-specific overrides within this routine

      t.timestamps
    end

    add_index :workout_routine_memberships, [:workout_routine_id, :workout_id],
              unique: true, name: 'idx_routine_memberships_unique'
    add_index :workout_routine_memberships, [:workout_routine_id, :position],
              name: 'idx_routine_memberships_pos'
  end
end
```

#### Migration 3: Create `workout_routine_offerings` table
Associates a routine tree with specific `course_offerings` in that term, capturing section-specific schedule offsets:
```ruby
class CreateWorkoutRoutineOfferings < ActiveRecord::Migration[6.0]
  def fk_type(table)
    column = ActiveRecord::Base.connection.columns(table).find { |c| c.name == 'id' }
    column.sql_type.include?('bigint') ? :bigint : :integer
  rescue
    :bigint
  end

  def change
    create_table :workout_routine_offerings do |t|
      t.references :workout_routine, type: fk_type(:workout_routines), null: false, foreign_key: true
      t.references :course_offering, type: fk_type(:course_offerings), null: false, foreign_key: true

      # Relative schedule offsets in minutes or days from section meeting schedule
      t.datetime :opening_date
      t.datetime :soft_deadline
      t.datetime :hard_deadline

      t.timestamps
    end

    add_index :workout_routine_offerings, [:workout_routine_id, :course_offering_id],
              unique: true, name: 'idx_routine_offerings_unique'
  end
end
```

---

## 4. Hierarchical Tree Architecture & Traversal

### 4.1 Adjacency List with Materialized Path (Ancestry Pattern)

To enable arbitrary nesting ($N$ levels deep) while keeping database reads fast, `WorkoutRoutine` uses an **adjacency list with a materialized path column (`ancestry`)**:
- Each root node has `ancestry: nil`.
- Each child node has `ancestry: "#{parent.id}"` or `"#{grandparent.id}/#{parent.id}"`.
- This provides $O(1)$ subtree and ancestor queries without recursive N+1 round trips:
  - Find all ancestors: `WorkoutRoutine.where(id: ancestry.split('/'))`
  - Find entire subtree: `WorkoutRoutine.where('ancestry = ? OR ancestry LIKE ?', path, "#{path}/%")`

### 4.2 ActiveRecord Model Definition (`app/models/workout_routine.rb`)

```ruby
class WorkoutRoutine < ApplicationRecord
  #~ Relationships ............................................................
  belongs_to :course, inverse_of: :workout_routines
  belongs_to :term, optional: true
  belongs_to :parent, class_name: 'WorkoutRoutine', optional: true, inverse_of: :children
  has_many   :children, -> { order(:position) }, class_name: 'WorkoutRoutine',
                        foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent

  belongs_to :workout_policy, optional: true

  has_many :memberships, -> { order(:position) },
           class_name: 'WorkoutRoutineMembership',
           dependent: :destroy,
           inverse_of: :workout_routine
  has_many :workouts, through: :memberships

  has_many :routine_offerings, class_name: 'WorkoutRoutineOffering',
                               dependent: :destroy,
                               inverse_of: :workout_routine
  has_many :course_offerings, through: :routine_offerings

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
    root? ? self : WorkoutRoutine.find(ancestry_ids.first)
  end

  def ancestry_ids
    ancestry.to_s.split('/').map(&:to_i)
  end

  def ancestors
    return [] if root?
    WorkoutRoutine.where(id: ancestry_ids).order(:id)
  end

  def path
    ancestors + [self]
  end

  def descendants
    path_str = ancestry.present? ? "#{ancestry}/#{id}" : id.to_s
    WorkoutRoutine.where('ancestry = ? OR ancestry LIKE ?', path_str, "#{path_str}/%")
  end

  def all_workouts
    Workout.where(id: all_membership_workout_ids)
  end

  def all_membership_workout_ids
    routine_ids = [id] + descendants.pluck(:id)
    WorkoutRoutineMembership.where(workout_routine_id: routine_ids).pluck(:workout_id).uniq
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

## 5. Cascading Settings & Inheritance Engine

### 5.1 Settings Inheritance Flowchart

When retrieving a setting for a workout within a routine (e.g., `time_limit` or `allowed_ips`), the resolution engine walks from the most specific context upward to the system defaults:

```
+-------------------------------------------------------------+
| 1. Workout Offering / Student Extension Override            |  (Student- or Section-specific)
|    - StudentExtension override?                             |
|    - WorkoutOffering local override?                        |
+------------------------------+------------------------------+
                               | if nil / inherit
                               v
+-------------------------------------------------------------+
| 2. Routine Membership Override                              |  (Workout within specific routine)
|    - WorkoutRoutineMembership#override_settings[key]        |
+------------------------------+------------------------------+
                               | if nil / inherit
                               v
+-------------------------------------------------------------+
| 3. Immediate Parent Routine                                 |  (Leaf / Group level)
|    - WorkoutRoutine#send(key)                               |
+------------------------------+------------------------------+
                               | if nil / inherit
                               v
+-------------------------------------------------------------+
| 4. Ancestor Routines (Bottom-up Traversal)                  |  (Branch / Category level)
|    - Walk parent -> grandparent -> root routine             |
+------------------------------+------------------------------+
                               | if nil / inherit
                               v
+-------------------------------------------------------------+
| 5. Global Course / System Default                           |  (Default baseline)
+-------------------------------------------------------------+
```

### 5.2 Inheritance Resolver Implementation

```ruby
class WorkoutRoutineSettingResolver
  CONFIG_ATTRIBUTES = %i[
    time_limit
    workout_attempt_limit
    score_to_keep
    workout_policy
    allowed_ips
    allowed_user_agents
    published
  ].freeze

  def initialize(workout_routine, workout = nil, course_offering = nil)
    @routine = workout_routine
    @workout = workout
    @course_offering = course_offering
  end

  # Resolves a specific attribute by cascading up the hierarchy
  def resolve(attr_name)
    # 1. Check Workout-Routine Membership override if workout is supplied
    if @workout.present?
      membership = @routine.memberships.find_by(workout: @workout)
      if membership&.override_settings.present?
        val = membership.parsed_overrides[attr_name.to_s]
        return val unless val.nil?
      end
    end

    # 2. Check routine and walk up ancestors (nearest ancestor wins)
    ([@routine] + @routine.ancestors.reverse).each do |node|
      val = node.read_attribute(attr_name)
      return val unless val.nil?
    end

    # 3. Fallback to default
    default_for(attr_name)
  end

  # Resolves all attributes into a consolidated hash
  def resolve_all
    CONFIG_ATTRIBUTES.each_with_object({}) do |attr, hash|
      hash[attr] = resolve(attr)
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

## 6. Multi-Section Semester Management for Teaching Teams

### 6.1 Unified Multi-Offering Coordination

In a university course:
1. The **Instructors author the hierarchy once** for the `Course` and `Term` (e.g., CS 1114, Fall 2026).
2. The tree of routines represents the canonical curriculum:
   - **Homework Routines** (HW 1, HW 2, ..., HW 10)
   - **In-Class Quiz Routines** (Quiz 1, Quiz 2, ..., Quiz 6)
   - **Exam Routines** (Midterm 1, Midterm 2, Final Exam)
3. **Sections Inherit Dates Relative to Section Schedules**:
   - Section 001 meets MWF at 10:10 AM.
   - Section 002 meets TR at 2:00 PM.
   - A routine offering can define relative timing (e.g., `due: class_end + 0 minutes` or relative day offsets).
4. **Instantiating WorkoutOfferings**:
   - A routine management service iterates through all sections in the semester and automatically creates or updates the corresponding `WorkoutOffering` records, applying the resolved cascading settings.

---

### 6.2 Declarative YAML Representation

To allow teachers to configure and version-control complex hierarchical routines across sections, the system supports a declarative YAML specification:

```yaml
routine: "Assessments"
description: "All graded quizzes and examinations for the semester"
settings:
  workout_policy:
    hide_feedback_before_finish: true
    invisible_before_review: true
    no_review_before_close: true
  allowed_user_agents: ["LockDown Browser", "SEB"]
  allowed_ips: "198.82.0.0/16"
  score_to_keep: "highest"

sub_routines:
  - routine: "Weekly Quizzes"
    settings:
      time_limit: 30
      workout_attempt_limit: 2
    workouts:
      - name: "Quiz 1: Java Basics"
        exercises: [101, 102, 103, 104]
      - name: "Quiz 2: Control Flow"
        exercises: [105, 106, 107, 108]

  - routine: "Midterm Exams"
    settings:
      time_limit: 75
      workout_attempt_limit: 1
    workouts:
      - name: "Midterm 1: Syntax & Methods"
        exercises: [201, 202, 203, 204, 205]

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

1. **Course Offerings "Routines" Manager**:
   - A visual, collapsible tree view (`<tree-view>`) in the instructor dashboard.
   - Teachers can drag-and-drop to reorder workouts within a routine, or move sub-routines into parent routines.
   - **Inheritance Badges**: Each node displays inherited vs. overridden settings with visual badges (e.g., `Time Limit: 30m [Inherited from Weekly Quizzes]`).
2. **Bulk Actions Dropdown**:
   - Click routine menu $\rightarrow$ *"Apply to All Sections in Fall 2026"*.
   - *"Emergency Schedule Shift"*: Shift all deadlines in this routine branch by $+X$ hours/days across all managed sections.
   - *"Publish Branch"*: Recursively publish all nested sub-routines and member workouts.

### 7.2 Student Experience

1. **Structured Workout View**:
   - Instead of a flat list of 40 unorganized workouts on the course page, students see an organized accordion:
     - **📁 Module 1: Basics** *(Completed 3/3)*
     - **📁 Module 2: Object-Oriented Programming** *(In Progress 1/4)*
       - **Workout 2.1: Class Declaration** (Score: 100%)
       - **Workout 2.2: Constructors** (Score: 85%)
2. **Contextual Breadcrumbs**:
   - When practicing a workout, the breadcrumb trail reflects the routine path:
     `CS 1114 > Fall 2026 > Module 2 > Sub-module 2.2 > Constructors Workout`.

---

## 8. Summary of Benefits & Implementation Checklist

### 8.1 Key Architectural Benefits

| Feature | Without Routines (Current) | With Hierarchical Routines |
| :--- | :--- | :--- |
| **Settings Configuration** | Configured individually on every single workout offering ($W \times S$ configurations). | Configured once at parent routine; cascades to all descendants automatically. |
| **Multi-Section Consistency** | Prone to drift between section settings; manual verification needed. | Single source of truth across all sections in the semester. |
| **Organization** | Flat list of workouts; difficult for students and staff to navigate. | Clean, arbitrarily deep tree structure matching course syllabus. |
| **Emergency Adjustments** | Must edit 20 separate workout offerings one by one. | Shift or edit parent routine; updates entire branch across all sections instantly. |

---

### 8.2 File-by-File Implementation Checklist

| Component | Files to Create / Modify | Responsibilities |
| :--- | :--- | :--- |
| **Database Migrations** | `db/migrate/YYYYMMDD_create_workout_routines.rb`<br>`db/migrate/YYYYMMDD_create_workout_routine_memberships.rb`<br>`db/migrate/YYYYMMDD_create_workout_routine_offerings.rb` | Create tables with `fk_type` foreign keys, indices, and materialized ancestry path. |
| **Models** | `app/models/workout_routine.rb`<br>`app/models/workout_routine_membership.rb`<br>`app/models/workout_routine_offering.rb`<br>`app/models/course.rb`<br>`app/models/workout.rb` | Implement hierarchy traversal, ancestry sync, cascading resolver, and associations. |
| **Services** | `app/services/workout_routine_setting_resolver.rb`<br>`app/services/workout_routine_offering_syncer.rb` | Handle cascading inheritance resolution and multi-section offering synchronization. |
| **Controllers** | `app/controllers/workout_routines_controller.rb`<br>`app/controllers/courses_controller.rb` | CRUD operations for routine tree, drag-and-drop reordering API, and bulk branch actions. |
| **Views & Helpers** | `app/views/workout_routines/_tree_node.html.haml`<br>`app/views/courses/_tab_workouts.html.haml`<br>`app/views/workouts/_form.html.haml` | Accordion/tree view for students; drag-and-drop hierarchy editor for instructors. |
| **Automated Specs** | `spec/models/workout_routine_spec.rb`<br>`spec/services/workout_routine_setting_resolver_spec.rb`<br>`spec/controllers/workout_routines_controller_spec.rb` | Unit and integration tests for hierarchy cycles, cascading settings, and multi-section sync. |
