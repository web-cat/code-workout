# CodeWorkout Gradebook CSV Export — Column Header Format & Structure

This document describes the structure, column header naming conventions, and data formatting used by the CodeWorkout Gradebook CSV export for section-level (`/course_offerings/:id/generate_gradebook.csv`) and course-level downloads.

---

## 1. Overview & Objectives

The CodeWorkout gradebook export serves two primary functions:
1. **LMS Grade Synchronization:** Direct, automatic matching when importing CSV grades into Learning Management Systems such as Canvas and Blackboard.
2. **Multi-Attempt Audit & Breakdown:** Transparent visibility into each individual attempt for workouts that allow multiple attempts, while preserving the officially recorded score.

---

## 2. Column Structure & Ordering

Columns are arranged in the following sequence:

1. **Student Identification Columns** (roster identification)
2. **Workout Grade Columns** (grouped by workout)
   - Primary Recorded Score Column
   - Attempt Breakdown Columns (when $K > 1$)
3. **Total Column** (sum of recorded workout scores)

### Layout Example

```text
Student Demographics | Workout A (Recorded) | Workout A (try 1) | Workout A (try 2) | Workout B (Recorded) | Total
```

---

## 3. Column Header Naming Conventions

### A. Student Demographics

* **Section Gradebook (`course_offerings#generate_gradebook`):**
  * `E-mail`
  * `First Name`
  * `Surname`
* **Course-wide Gradebook (`courses#generate_gradebook`):**
  * `Course Offering Id`
  * `Course Offering`
  * `First Name`
  * `Second Name`

### B. Primary Recorded Score Column

The primary workout column contains the officially kept score (evaluated against the workout offering's scoring policy).

* **Standard Format:**
  ```text
  #{workout.name} (#{workout.id})
  ```
  *Example:* `Recursion Practice (42)`
* **With LMS / LTI Assignment Link:**
  ```text
  #{workout.name} (#{workout.id}, #{workout_offering.lti_assignment_id})
  ```
  *Example:* `Recursion Practice (42, lti_a39f1c7d)`

> **LMS Compatibility:** The primary column format matches the identifier expected by Canvas and Blackboard CSV importers, ensuring seamless grade sync.

### C. Attempt Breakdown Columns

When a workout offering allows multiple attempts or students have completed multiple attempts, individual attempt columns appear immediately following the workout's primary column:

```text
#{workout.name} (#{workout.id}, try #{attempt_number})
```

*Examples:*
* `Recursion Practice (42, try 1)`
* `Recursion Practice (42, try 2)`
* `Recursion Practice (42, try 3)`

---

## 4. Attempt Column Count ($K$) Calculation

The number of attempt columns ($K$) generated for a workout is dynamically calculated:

$$K = \max(\text{offering attempt limit}, \text{max attempts taken by any student}, \text{max extension attempt limit})$$

* **Single-Attempt Workouts ($K \le 1$):** Only the primary recorded score column is rendered. No redundant attempt columns are added.
* **Multi-Attempt Workouts ($K > 1$):** Renders the primary column followed by $K$ attempt columns (`try 1` through `try K`).
* **Student Extensions:** If an individual student is granted additional attempts beyond the offering's default limit, $K$ expands to accommodate the highest attempt without truncating any student's record.
* **Unlimited Workouts:** If a workout has unlimited attempts, $K$ equals the highest attempt number actually completed by enrolled students in that section.

---

## 5. Cell Value Population Rules

| Column Type | Student Completed Attempt | Student Has Not Taken Attempt |
| :--- | :--- | :--- |
| **Primary Recorded Score** | Kept score (rounded to 2 decimal places, e.g., `85.0`) based on `workout_score_to_keep` (`highest` or `latest`) | Empty string `""` (or `'Not attempted'` in course view) |
| **Attempt Column (`try X`)** | Score achieved on Attempt $X$ (rounded to 2 decimal places) | Empty string `""` |
| **Total** | Sum of all **primary recorded scores** for the student. | `0.0` if no workouts completed |

> **Important:** Attempt columns (`try 1`, `try 2`, etc.) are **excluded** from the `Total` column to prevent scores from being inflated or double-counted.

---

## 6. Sample CSV Output

### Example: Section with a Multi-Attempt Workout and a Single-Attempt Workout

Workout 42 (`Variables & Types`) allows 3 attempts. Workout 107 (`Loops`) allows 1 attempt.

```csv
E-mail,First Name,Surname,Variables & Types (42),Variables & Types (42, try 1),Variables & Types (42, try 2),Variables & Types (42, try 3),Loops (107),Total
alice@example.com,Alice,Wonderland,95.0,70.0,95.0,,80.0,175.0
bob@example.com,Bob,Builder,60.0,60.0,,,,60.0
charlie@example.com,Charlie,Brown,,,,,,0.0
```

* **Alice:** Took 2 attempts on Workout 42 (got 70.0, then 95.0; kept score is 95.0). Completed Workout 107 (80.0). Total = 175.0. Attempt 3 is blank.
* **Bob:** Took 1 attempt on Workout 42 (60.0). Has not attempted Workout 107. Total = 60.0. Attempts 2 and 3 are blank.
* **Charlie:** Has not started either workout. All score cells are blank. Total = 0.0.

---

## 7. Security and Access Control

Access to gradebook downloads is restricted by CanCanCan:
* **Section Gradebook (`course_offerings#generate_gradebook`):**
  Guarded by `load_and_authorize_resource`. Only users with `is_staff?` permission on the course offering (instructors, graders) or global administrators can download grades. Students and unauthenticated visitors receive an HTTP `403 Forbidden` (`CanCan::AccessDenied`).
* **Supported HTTP Methods:**
  Routes accept `GET`, `POST`, and `HEAD` requests (`via: [:get, :post]`) to support browser downloads, `button_to` actions, and HTTP preflight checks without routing errors.
