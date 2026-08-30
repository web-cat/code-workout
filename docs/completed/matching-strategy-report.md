# LTI Course/Workout Matching Strategy — Comprehensive Analysis & Proposal

## Table of Contents

1. [Overview](#overview)
2. [Branch 1: `master` — Current Production Strategy](#branch-1-master--current-production-strategy)
3. [Branch 2: `new-course-matching-strategy`](#branch-2-new-course-matching-strategy)
4. [Branch 3: `new-course-matching-strategy2`](#branch-3-new-course-matching-strategy2)
5. [Branch 4: `passport-api`](#branch-4-passport-api)
6. [Comparative Summary](#comparative-summary)
7. [Best-of-Breed Proposal](#best-of-breed-proposal)

---

## Overview

When an LTI launch request arrives from an LMS (e.g., Canvas), CodeWorkout must resolve it into a specific `User`, `CourseOffering`, and `WorkoutOffering`. The logic is split across two controllers:

- **`LtiController#launch`** — Authenticates the LTI request, resolves the user identity, organization, course, and term, then redirects to `find_offering`.
- **`WorkoutsController#find_offering`** — The core matching method. Resolves the appropriate `WorkoutOffering` for the user, creating or cloning resources as needed.

The matching strategy differs significantly between instructor and student flows, and has evolved across four branches. Each branch adjusts how the system identifies the right `CourseOffering` and `WorkoutOffering` — and what happens when no match is found.

---

## Branch 1: `master` — Current Production Strategy

### LTI Controller (`launch`)

The master branch extracts from the LTI payload:

- `ext_lti_assignment_id` — an LMS-level assignment identifier
- `custom_canvas_assignment_id` — a Canvas-specific numeric assignment ID
- `lms_instance_id` — identifies which LMS installation originated the request
- `dynamic_lms_assignment` — flag indicating the assignment ID can change

These are forwarded to `find_offering` via query parameters. Notably, `context_id` (the LTI context ID identifying the course section in the LMS) is **not** forwarded.

### `find_offering` Strategy

#### Identifier Construction

Two composite assignment IDs are constructed:

```ruby
@lms_assignment_id = "#{lms_instance_id}-#{ext_lti_assignment_id}"
@custom_canvas_lms_assignment_id = "#{lms_instance_id}-#{custom_canvas_assignment_id}"
```

These compound keys are stored on `WorkoutOffering.lms_assignment_id` and used as the primary matching key.

#### Instructor Path

1. **Search by `lms_assignment_id`**: Look for `WorkoutOffering` records matching the compound assignment ID (trying both the ext and Canvas variants).
2. **Fallback to name + term**: If no match, search for workout offerings the instructor manages in the current term with a matching workout name.
3. **Fallback to past terms**: If still no match, search all past terms for a managed workout offering to find a cloneable workout.
4. **Auto-create CourseOffering**: If the instructor has no managed `CourseOffering` in the current term, one is automatically created with a label derived from the instructor's name and term.
5. **Auto-create WorkoutOffering**: If a `from_collection` workout (e.g., OpenDSA) is identified, a `WorkoutOffering` is auto-created and attached.
6. **Clone / New redirect**: If a workout was found in past terms but isn't from a collection, redirect to the clone page. Otherwise, redirect to the "new or existing workout" page.

#### Student Path

1. **Search by `lms_assignment_id`**: Same compound-key search.
2. **Sister offerings**: If a match is found, also look for "sister" `WorkoutOffering` records (same course, term, workout but with no `lms_assignment_id`) and include them in the pool.
3. **Label-based fallback**: If a `custom_label` param was sent, find the `CourseOffering` by exact label match.
4. **Enrollment check**: Try to narrow to a `WorkoutOffering` the student is enrolled in.
5. **Self-enrollment**: If the student isn't enrolled, check for self-enrollment-allowed offerings. If exactly one exists, auto-select it. Otherwise, render a selection page.
6. **Instructor lookup**: If a course offering is found but no workout offering, use the course offering's instructor to search for workout offerings by name (current term, then past terms), and auto-create the `WorkoutOffering` if a workout is found.
7. **`add_workout` fallback**: If the student is enrolled in a course offering but no workout offering exists, use `CourseOffering#add_workout` to create one.

#### Post-Resolution

- Binds the `lms_instance_id` to the course offering if missing.
- Sets or resets the `lms_assignment_id` on the workout offering (controlled by `dynamic_lms_assignment`).
- Auto-enrolls the user if not enrolled (with appropriate role).
- Redirects to the practice page.

### Strengths

- **Mature & battle-tested**: This is the production strategy that has handled real traffic.
- **Comprehensive student fallback chain**: Multiple paths ensure students eventually reach a workout.
- **Sister offering discovery**: Ensures all sections of a course share the workout even if not all were LTI-linked initially.
- **Auto-create with guardrails**: Only instructors can trigger auto-creation of courses and course offerings.

### Weaknesses

1. **No `lti_context_id`**: The master branch never forwards or uses the LMS context ID (the unique identifier for the course section in the LMS). This means there's no reliable way to tie a `CourseOffering` to a specific LMS course section. Matching relies entirely on the fragile combination of organization/course slug + instructor + term.
2. **Compound `lms_assignment_id`**: The `"lms_instance_id-ext_assignment_id"` format creates an opaque, synthetic key that couples two separate identifiers. If either changes (e.g., LMS migration, assignment re-creation), the key breaks.
3. **Ambiguous multi-offering resolution**: When multiple workout offerings match for an instructor, the code picks `.flatten.first` — which is essentially random/insertion-order.
4. **Auto-create side effects**: Automatic course offering creation (labeled with the instructor's name) creates orphan offerings if the same instructor launches from different course sections in the LMS.
5. **`dynamic_lms_assignment` race condition**: The flag allows overwriting a workout offering's assignment ID. If two different LMS assignments point to the same workout, the second one silently overwrites the first's assignment link.
6. **No idempotency**: Multiple identical LTI launches can create duplicate course offerings or workout offerings under certain timing conditions.
7. **Session-based `is_instructor` check**: The `session[:is_instructor]` flag is used instead of the more reliable `params[:is_instructor]` that was extracted from the LTI payload, creating potential session staleness issues.

---

## Branch 2: `new-course-matching-strategy`

### Key Changes

This branch introduces the `lti_context_id` concept and restructures the instructor flow.

#### Schema Changes

- Adds `lti_context_id`, `lms_course_id`, and `lms_section_id` columns to `course_offerings`.
- Adds a migration for these fields.

#### LTI Controller Changes

- Forwards `context_id` from the LTI payload as `lti_context_id` to `find_offering`.

#### `find_offering` Instructor Path Rewrite

The instructor path is substantially rewritten:

1. **Search by `lms_assignment_id`**: Uses `find_by` (returns one record) instead of `where` (returns a collection). This is more intentional about expecting a single match.
2. **Term-based fallback**: Same as master.
3. **LTI context-based course offering lookup**: Instead of auto-creating a course offering, looks for existing `CourseOffering` records by `lti_context_id`.
4. **`select_offering` UI**: If multiple course offerings exist for the instructor (found by term or lti_context_id), redirects to a **new `select_offering` page** where the instructor explicitly chooses which course offerings to bind to the LTI context.
5. **Batch course offering creation**: The `create` action is rewritten to support creating multiple course offerings at once (via a `labels[]` array), sharing common term, URL, and cutoff date settings.

#### New `select_offering` Action

A new `CourseOfferingsController#select_offering` action (GET/POST) allows instructors to:

- View candidate course offerings for their course+term
- Select one or more to bind to the LTI context ID
- Automatically create workout offerings for the selected course offerings

#### Course Offering Form Rewrite

- Completely rewritten using `form_tag` instead of `semantic_form_for`
- Supports multiple offering labels
- Carries forward all LTI params as hidden fields

#### `CourseOffering` Model Addition

- Adds `find_workout_offerings(workout)` helper method for looking up workout offerings by workout object or name string.

### Strengths

1. **LTI context binding**: Introducing `lti_context_id` creates a stable, LMS-provided identifier for course sections. This dramatically improves matching accuracy.
2. **Explicit offering selection**: Instead of auto-creating, the instructor explicitly selects which offerings to bind. This reduces orphan records and mismatches.
3. **Batch creation**: Supporting multi-offering creation is operationally useful for instructors with many sections.
4. **`find_by` over `where`**: Using `find_by` makes the "exactly one match" assumption explicit.

### Weaknesses

1. **Incomplete instructor flow**: The `lti_context_id` lookup is wired up, but the flow between "found by context ID" and "create workout offering" has control-flow issues — `to_b?` is called (with `?`) instead of `to_b` on one line, which would cause a `NoMethodError`.
2. **Student path unchanged**: The student path still uses the old compound `lms_assignment_id` matching, losing the benefit of `lti_context_id`.
3. **Removed auto-create**: Removing the auto-create of course offerings may break first-launch flows for new courses where no offering has been pre-created.
4. **Incomplete `allow_iframe`**: Adds `before_action :allow_iframe` but the implementation isn't shown — may cause X-Frame-Options issues if not implemented.
5. **No `lms_instance_id` scoping on `lti_context_id`**: The `lti_context_id` is looked up globally (`CourseOffering.where(lti_context_id: ...)`). Since `lti_context_id` values may collide across LMS instances, this could match the wrong offering.
6. **Commented-out code in strategy2**: The branch appears to have been the basis for `strategy2`, which is in a state of heavy code commenting — suggesting the approach was abandoned mid-implementation.

---

## Branch 3: `new-course-matching-strategy2`

### Key Changes

This branch is a variant of `new-course-matching-strategy` with notable differences:

1. **Heavily commented-out instructor path**: The entire original instructor matching logic is commented out with `# mark out` annotations. Only the `lti_context_id`-based lookup and `select_offering` redirect survive.
2. **Same student path**: Identical to master, with no changes.
3. **Same schema changes**: Same `lti_context_id`, `lms_course_id`, `lms_section_id` additions as strategy 1.
4. **Debug artifacts**: Contains debugging comments (`# p "in find offering /&&&&&&&&&&&&&&"`) and partial comment blocks suggesting active development was interrupted.

### Strengths

1. **Simpler instructor path**: By commenting out the complex cascading fallbacks, the intent becomes clearer — match by `lti_context_id` or prompt the instructor.
2. **Same `select_offering` UI**: Retains the explicit selection approach.

### Weaknesses

1. **Non-functional instructor path**: With the core matching logic commented out, the instructor path effectively only works for the `lti_context_id` and `select_offering` cases. Many edge cases (first-time launch, no existing offerings) would fall through without resolution.
2. **Stale state**: This branch appears to be an abandoned mid-refactor snapshot. It should not be used directly.
3. **No new correctness improvements over strategy 1**: The functional code is a subset of strategy 1 with the same bugs (e.g., missing `lms_instance_id` scoping on context ID lookups).

---

## Branch 4: `passport-api`

### Key Changes

This branch represents the most modern iteration, incorporating new schema columns and additional matching strategies.

#### Schema Changes on `WorkoutOffering`

- Adds `lti_assignment_id` (string) — stores the raw `ext_lti_assignment_id`
- Adds `lms_instance_id` (FK to `lms_instances`) — direct reference instead of embedded in compound key
- Adds compound unique index `(lms_instance_id, lti_assignment_id)` — ensures one-to-one assignment mapping per LMS
- Retains `lms_assignment_id` — now stores Canvas-specific `custom_canvas_assignment_id`

#### Schema Changes on `CourseOffering`

- Adds `canvas_course_id` column in addition to `lti_context_id`
- Adds indexes on both columns

#### LTI Controller Changes

- Forwards `lti_context_id` (from `params[:context_id]`) and `canvas_course_id` (from `params[:custom_canvas_course_id]`) to `find_offering`.
- Uses `@lti_token` instead of a boolean for `lti_launch`, supporting more advanced LTI session tracking.

#### `find_offering` Strategy

**Identifier handling:**

- Does **not** construct compound keys. Instead, uses raw identifiers:
  ```ruby
  @custom_canvas_lms_assignment_id = custom_canvas_assignment_id  # raw
  @lms_assignment_id = ext_lti_assignment_id  # raw
  ```
- Stores them separately: `lms_assignment_id` for Canvas ID, `lti_assignment_id` for the LTI ext ID.

**Instructor path:**

1. **Priority CourseOffering lookup**: Before any workout search, tries to find a `CourseOffering` by `lti_context_id`, then by `canvas_course_id`.
2. **`lms_instance_id`-scoped workout search**: Searches `WorkoutOffering` with *both* `lms_instance_id` and `lti_assignment_id`, avoiding cross-LMS collision.
3. **Fallback chain**: Same cascading term → past-term → auto-create as master.
4. **New identifier storage**: When auto-creating workout offerings, stores both `lms_assignment_id` and `lti_assignment_id` separately.
5. **Context ID on auto-create**: When auto-creating a course offering, includes `lti_context_id` and `canvas_course_id`.

**Student path:**

1. **`lms_instance_id`-scoped search**: Student search also uses `(lms_instance_id, lti_assignment_id)` and `(lms_instance_id, lms_assignment_id)`.
2. **Better multi-match handling**: If exactly one workout offering exists, uses it even without enrollment. If multiple exist, renders a selection page.
3. **Separate LTI/LMS ID assignment**: Updates both `lti_assignment_id` and `lms_assignment_id` independently, with separate change-detection logic.
4. **Enrollment relaxation**: Allows auto-enrollment when `matching_lms_assignment_id` is true, even if `can_enroll?` is false — reflecting the trust model of "if the LMS says this student should access this assignment, enroll them."

**Post-resolution ID management:**

```ruby
if @workout_offering.lti_assignment_id.blank? || should_reset_lms_assignment_id
  @workout_offering.lti_assignment_id = @lms_assignment_id
end
if @workout_offering.lms_assignment_id.blank? || (... && dynamic_lms_assignment)
  @workout_offering.lms_assignment_id = @custom_canvas_lms_assignment_id
end
if @workout_offering.changed?
  @workout_offering.save
end
```

### Additional Model Changes

- `WorkoutOffering` adds `belongs_to :lms_instance` relationship.
- `WorkoutOffering` adds `before_validation :ensure_workout_policy` callback (auto-creates a policy from the workout's default if none exists).
- `WorkoutOffering#can_be_practiced_by?` is rewritten with proper enrollment checks.
- `WorkoutOffering#hard_deadline_for` is improved to properly cascade extension → offering hard → extension soft → offering soft deadlines.
- Uses `ApplicationRecord` instead of `ActiveRecord::Base`.

### Strengths

1. **Decoupled identifiers**: Splitting `lti_assignment_id` from `lms_assignment_id` is the architecturally correct approach. Each column stores exactly one identifier with clear semantics.
2. **`lms_instance_id` scoping**: The compound unique index `(lms_instance_id, lti_assignment_id)` prevents cross-LMS collisions — the most critical correctness improvement.
3. **Multiple matching anchors**: Using both `lti_context_id` and `canvas_course_id` for course offering resolution provides defense-in-depth.
4. **Dirty-check before save**: `@workout_offering.changed?` prevents unnecessary writes.
5. **Better student multi-match**: Handling exactly-one and multiple cases separately improves UX.
6. **Session-based instructor check**: Uses `session[:is_instructor]` which is set from the LTI payload during `launch`, improving reliability.

### Weaknesses

1. **Still retains auto-create**: Auto-creating course offerings with synthetic labels (`"instructor-name - term"`) is still present for cases where no offering exists.
2. **Variable shadowing**: `dynamic_lms_assignment` is assigned to `params[:dynamic_lms_assignment]` as a raw string, but used as a boolean in the post-resolution section without `.to_b`. This could cause bugs if the string value is `"false"`.
3. **No `select_offering` UI**: Unlike the `new-course-matching-strategy` branches, this branch doesn't offer an explicit offering selection page for instructors.
4. **Global `lti_context_id` lookup**: The `CourseOffering.find_by(lti_context_id: ...)` at the top of `find_offering` is not scoped to the course or organization. Since `lti_context_id` values are globally unique within an LMS but not across LMS instances, this could match incorrectly without `lms_instance_id` scoping.
5. **Migration complexity**: Adding `lms_instance_id` FK to `workout_offerings` requires a data migration for existing records.

---

## Comparative Summary

| Feature                                                          | `master`       | `strategy`    | `strategy2` | `passport-api` |
| ---------------------------------------------------------------- | ---------------- | --------------- | ------------- | ---------------- |
| **`lti_context_id` on CourseOffering**                   | ❌               | ✅              | ✅            | ✅               |
| **`canvas_course_id` on CourseOffering**                 | ❌               | ❌              | ❌            | ✅               |
| **Separate `lti_assignment_id` / `lms_assignment_id`** | ❌ (compound)    | ❌ (compound)   | ❌ (compound) | ✅               |
| **`lms_instance_id` on WorkoutOffering**                 | ❌               | ❌              | ❌            | ✅               |
| **Unique index on (lms_instance, lti_assignment)**         | ❌               | ❌              | ❌            | ✅               |
| **Instructor selection UI**                                | ❌ (auto-create) | ✅              | ✅ (partial)  | ❌ (auto-create) |
| **Cross-LMS collision prevention**                         | ❌               | ❌              | ❌            | ✅               |
| **Student path improvements**                              | Baseline         | Unchanged       | Unchanged     | Improved         |
| **Code quality**                                           | Stable           | Bug (`to_b?`) | Abandoned     | Mostly clean     |
| **Production readiness**                                   | ✅               | ❌              | ❌            | Partial          |

---

## Best-of-Breed Proposal

### Design Principles

1. **LMS-provided identifiers are the primary matching keys** — not synthetic compound keys.
2. **Scoping by `lms_instance_id`** — all identifier lookups must be scoped to the originating LMS to prevent cross-instance collisions.
3. **Explicit instructor actions** — instructors should confirm course offering bindings, not have them auto-created with synthetic labels.
4. **Cascading resolution** — fail gracefully through a well-defined priority chain.
5. **Idempotency** — repeated identical LTI launches must not create duplicate records.

### Schema

Adopt passport-api's schema additions with one enhancement:

#### `course_offerings`

| Column               | Type                | Notes                                                                                                  |
| -------------------- | ------------------- | ------------------------------------------------------------------------------------------------------ |
| `lti_context_id`   | string              | LTI `context_id` from payload                                                                        |
| `canvas_course_id` | string              | Canvas `custom_canvas_course_id`                                                                     |
| `lms_section_id`   | string              | Canvas `custom_section_ids` (via `$Canvas.course.sectionIds`) — critical for cross-listed courses |
| `lms_instance_id`  | FK → lms_instances | Already exists, ensure populated                                                                       |

**Index:** `(lms_instance_id, lti_context_id, lms_section_id)` UNIQUE — scoped to prevent cross-LMS and cross-section collision.

#### `workout_offerings`

| Column                | Type                | Notes                                                                           |
| --------------------- | ------------------- | ------------------------------------------------------------------------------- |
| `lti_assignment_id` | string              | Raw `ext_lti_assignment_id` from LTI                                          |
| `lms_assignment_id` | string              | Raw Canvas `custom_canvas_assignment_id`                                      |
| `resource_link_id`  | string              | Standard LTI 1.1 `resource_link_id` (essential fallback for non-Canvas LMSes) |
| `lms_instance_id`   | FK → lms_instances | Direct reference                                                                |

**Index:** `(lms_instance_id, lti_assignment_id)` UNIQUE
**Index:** `(lms_instance_id, resource_link_id)` UNIQUE

### LTI Controller (`launch`)

Forward all available identifiers to `find_offering`:

```ruby
redirect_to organization_find_workout_offering_path(
  # ... existing params ...
  lti_context_id: params[:context_id],
  canvas_course_id: params[:custom_canvas_course_id],
  lms_section_id: params[:custom_section_ids],
  resource_link_id: params[:resource_link_id],
  ext_lti_assignment_id: ext_lti_assignment_id,
  custom_canvas_assignment_id: custom_canvas_assignment_id,
  lms_instance_id: @lms_instance.id,
  # ... other params ...
)
```

### `find_offering` — Proposed Algorithm

```
INPUTS:
  user, course, term, organization
  lms_instance_id, lti_context_id, canvas_course_id, lms_section_id (parsed to array)
  ext_lti_assignment_id, custom_canvas_assignment_id, resource_link_id
  context_label, context_title, section_names (parsed to array)
  workout_name, from_collection, dynamic_lms_assignment
  is_instructor (from session, set during LTI launch)
```

#### Phase 1: Resolve CourseOffering (shared by instructors and students)

*Note: The `lms_section_id` parameter can be a comma-separated list if a user is in multiple cross-listed sections. It must be split into an array to generate an SQL `IN` query.*

```
1. Try: CourseOffering.where(lms_instance_id:, lti_context_id:, lms_section_id: [array_of_ids])
2. Try: CourseOffering.where(lms_instance_id:, canvas_course_id:, lms_section_id: [array_of_ids])
   → If exactly one found, use it and backfill lti_context_id or lms_section_id if blank
   → If multiple found, proceed to resolution step (select page)
3. Try: User's enrolled/managed offerings for (course, term)
   → If exactly one, use it and backfill identifiers
   → If multiple, proceed to resolution step
4. If none found → branch to instructor/student-specific handling
```

#### Phase 2: Resolve WorkoutOffering (scoped by resolved CourseOffering if available)

```
1. Try: WorkoutOffering.find_by(lms_instance_id:, lti_assignment_id:)
2. Try: WorkoutOffering.find_by(lms_instance_id:, lms_assignment_id:)
3. Try: WorkoutOffering.find_by(lms_instance_id:, resource_link_id:)
4. If course_offering resolved:
   a. Search course_offering.workout_offerings by workout name
5. Fallback: Search user's managed/enrolled offerings by name in current term
```

#### Phase 3: Create or Select (when no match found)

**Instructor path:**

```
1. Search past terms for workout by name → found_workout
2. Collect candidate course offerings:
   a. CourseOffering.where(lms_instance_id:, lti_context_id:, lms_section_id: [array_of_ids])
   b. OR user.managed_course_offerings(course:, term:)
3. If candidates found → redirect to select_offering page
   (instructor picks which offerings to bind to this LTI context)
4. If no candidates → redirect to new_course_offering page
   (pre-filled with LTI params as hidden fields)
   * UI Prompt: Ask instructor to choose between creating a single course offering (bound to the parent `lti_context_id`) OR batch-create multiple offerings for each `lms_section_id` present. The default for the choice should be based on the presence/absence of multiple lms_section_id values. 
   * **Label Pre-filling**: The UI should automatically pre-fill the offering label(s) using data from the LTI launch:
     - For single or multiple section offerings: Use the Canvas `custom_section_names` (populated via `$com.instructure.User.sectionNames` and parsed to an array) to precisely label each corresponding `lms_section_id`. 
     - If custom section names are not available:
       - For a single offering: Use the standard LTI `context_label` (e.g., "CS101") or `context_title` (e.g., "Intro to CS").
       - For multiple section offerings: Use the standard LTI `context_label` (e.g., "CS101") or `context_title` (e.g., "Intro to CS"), followed by " - " and the lms_section_id.
   * The instructor can edit any pre-filled labels before saving.
5. After course offering(s) resolved:
   a. If from_collection && found_workout → auto-create WorkoutOffering
   b. If found_workout → redirect to clone page
   c. Otherwise → redirect to new_or_existing_workout page
```

**Student path:**

```
1. If enrolled in exactly one course offering for this course+term:
   a. Use the offering's instructor to search for workout
   b. Auto-create WorkoutOffering if from_collection
   c. Do not use add_workout fallback otherwise--instead, display an error message to the student that the workout
      is not yet available and to contact their instructor.
2. If multiple enrollment-eligible offerings → render selection page
3. If no eligible offerings → error: "contact your instructor"
```

#### Phase 4: Post-Resolution (shared)

```
1. Backfill course_offering.lms_instance_id if blank
2. Backfill course_offering.lti_context_id and lms_section_id if blank
3. Set workout_offering.lti_assignment_id if blank (or if dynamic)
4. Set workout_offering.lms_assignment_id if blank (or if dynamic)
5. Set workout_offering.resource_link_id if blank
6. Set workout_offering.lms_instance_id if blank
7. Only save if changed? (dirty-check)
8. Auto-enroll user with appropriate role if not already enrolled
9. Redirect to practice page
```

### Key Differences from All Existing Branches

| Change                                                                                                     | Rationale                                                                                                  |
| ---------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| **All identifier lookups scoped by `lms_instance_id`**                                             | Prevents the global-lookup collision bug present in all branches                                           |
| **Unique index `(lms_instance_id, lti_context_id, lms_section_id)` on course_offerings**           | Enforces 1:1 mapping between LMS section and CodeWorkout offering per LMS instance                         |
| **Addition of `resource_link_id` and `lms_section_id`**                                          | Explicitly supports standard LTI placement tracking and Canvas cross-listed sections                       |
| **Instructor `select_offering` page** (from strategy branches) combined with passport-api's schema | Best of both: proper identifiers + explicit UX                                                             |
| **No auto-create of CourseOffering**                                                                 | Instructors must explicitly create or bind offerings. Eliminates orphan records                            |
| **Backfill strategy**                                                                                | When a record is matched by a legacy key, newer identifiers are populated automatically for future lookups |
| **`session[:is_instructor]`** (from passport-api)                                                  | Reliable role determination set during LTI payload processing                                              |
| **Separate `lti_assignment_id` + `lms_assignment_id`** (from passport-api)                       | Proper identifier separation instead of compound keys                                                      |
| **Dirty-check before save** (from passport-api)                                                      | Prevents unnecessary DB writes                                                                             |

### Migration Path

1. **Add columns and indexes** to `course_offerings` and `workout_offerings` as described.
2. **Data migration**: Parse existing compound `lms_assignment_id` values (`"instance_id-assignment_id"`) and split into the new separate columns. Populate `lms_instance_id` on workout offerings.
3. **Backfill `lti_context_id`**: For course offerings with an `lms_instance_id`, attempt to populate `lti_context_id` from LTI launch logs if available.
4. **Deploy new `find_offering`**: The new algorithm is backward-compatible — it tries new identifiers first but falls back to name-based matching.
5. **Retain old columns temporarily**: Keep the compound `lms_assignment_id` readable for fallback during transition.
6. **Remove compound-key logic** after one full semester of dual-write operation.

### Risk Mitigation

- **Logging**: Add structured logging for every matching step (which identifier matched, which fallback was used) to diagnose issues during rollout.
- **Monitoring**: Alert on frequent fallback-to-name-matching, which indicates identifiers are not being populated correctly.
- **Feature flag**: Gate the new matching strategy behind a feature flag so it can be disabled per-organization during rollout.
- **Backward compatibility**: Maintain support for old compound `lms_assignment_id` lookups in the fallback chain for at least one semester.
