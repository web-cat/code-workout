## Current Session: Workouts Tab Sorting & Dynamic Filtering (Complete)

### Implementation Summary
1. **Default Ordering by Due Date:**
   - Implemented in `CoursesHelper#course_workout_items` ([`app/helpers/courses_helper.rb`](file:///Users/edwards/git/code-workout/app/helpers/courses_helper.rb)):
     - Computes earliest due date (`soft_deadline || hard_deadline`, with student extension override for students).
     - Workouts without due dates sort to the end.
     - Secondary tie-break is alphabetical by workout name.
     - Automatically aggregates `min_from` (opening date), `max_closed` (closed date), and `due_date` across all offerings for a workout.
2. **Sorting Control:**
   - Added `#workout-sort-select` popup control at the top of the workouts tab with options:
     - Due date (earliest first, default)
     - Opening date (earliest first)
     - Alphabetical (A-Z)
     - Due date (descending)
     - Opening date (descending)
     - Alphabetical (descending)
   - Dynamic client-side DOM reordering implemented in `applyWorkoutSort()` ([`app/assets/javascripts/course.js.coffee`](file:///Users/edwards/git/code-workout/app/assets/javascripts/course.js.coffee)).
3. **Dynamic Name Filter:**
   - Filter input `#workout-filter-name` with search icon and clear button `.workout-clear-name` matching the grades tab student filter pattern.
   - Real-time case-insensitive filtering with Enter key submission prevention and Esc/clear button reset.
4. **State Filters Popup List:**
   - Bootstrap dropdown `#workout-state-filter-btn` with multi-select checkboxes for inclusion/exclusion:
     - `open`: Current date is within available from/until dates (`min_from` .. `max_closed`).
     - `past_due`: Current date is after due date.
     - `past`: Current date is after max closed date.
     - `future`: Current date is before min from date.
     - `published` / `unpublished`: Offering publication status (for instructors).
   - Keeps popup open on checkbox toggle (`e.stopPropagation()`).
   - Includes "Reset state filters" link to quickly clear state filters.
   - Button text dynamically reflects active selection (e.g., "State: All", "State: Open", "State: Open, Past due", "State: (3 selected)").
5. **Modern Responsive Grid Layout:**
   - Replaced brittle static `in_groups_of(2, false)` + `.clearfix` with a responsive flex container (`.workouts-list` + `.workout-card`) in [`app/assets/stylesheets/custom.scss`](file:///Users/edwards/git/code-workout/app/assets/stylesheets/custom.scss).
   - Eliminates layout breaks when items are filtered or dynamically reordered.
   - Shows informative alert `.workout-no-matches` when filters yield no results.

### Verification Evidence
- `spec/helpers/courses_helper_spec.rb`: 5 examples, 0 failures.
- `spec/views/courses/_tab_workouts.html.haml_spec.rb`: 3 examples, 0 failures.
- Total: 8 examples, 0 failures across helper and view specs.
