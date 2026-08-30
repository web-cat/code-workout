You are a human-computer interaction and user interface expert with deep knowledge about methods for representing structured data that are easy for humans to read and to write.
You are designing a data representation for a software tool that is used to create and update recurring deadlines.
These deadlines are for assignments in educational courses. Situations to handle include a single course section with one deadline or multiple sections with separate deadlines and
repeating weekly patterns of deadlines for each assignment (e.g., section 1 has weekly labs due on mondays at 10am while section 2 has them due on tuesdays at 3pm, etc.). You also
want to support listing individual student overrides, where a specific assignment has a different due date for an individual student or set of students.
Design a concise, clear, human-friendly data representation that is easy to edit, store, and update in plain text files and that is also easy to process by scripting code.
Place your description of the format, including examples and a clear explanation of how to use its features, on the canvas.

That's a fantastic challenge\! Designing a data format for recurring deadlines with complex variations requires balancing **human readability and editability** with **machine parseability**.

For this scenario—structured, hierarchical data that needs to be easily read, written, and updated in plain text—the **YAML (YAML Ain't Markup Language)** format is an ideal choice. It's a superset of JSON, offering a clean, indentation-based structure that is highly human-friendly while being natively supported by virtually all modern programming languages for parsing and serialization.

---

## 🎨 **YAML-Based Deadline Data Representation**

This design uses a hierarchical YAML structure, starting with the course, then assignments, then section-specific schedules, and finally, individual student overrides.

### **1. Format Structure and Features**

| Feature                     | YAML Implementation                                                             | Rationale                                                                   |
| :-------------------------- | :------------------------------------------------------------------------------ | :-------------------------------------------------------------------------- |
| **Top Level**         | An outer**dictionary (map)** for the course name/ID.                      | Provides clear context and a single root element.                           |
| **Assignments**       | A list of assignment**objects** under the `assignments` key.            | Allows easy iteration and clear separation of distinct assignments.         |
| **Default Schedule**  | A `default_schedule` object within each assignment.                           | Defines the base pattern (what happens if no section-specific rule exists). |
| **Section Overrides** | A list of `section_schedules` to override the default.                        | Uses the `section_id` as a key to target specific groups.                 |
| **Recurring Pattern** | Uses keys like `day_of_week`, `time`, and `interval` (e.g., `weekly`).  | Concise, self-documenting pattern definition.                               |
| **Student Overrides** | A `student_overrides` list with explicit `student_id` and new `due_date`. | Handles exceptions clearly at the lowest level of the hierarchy.            |

---

### **2. Example Data File (`deadlines.yaml`)**

This example demonstrates a single course with one assignment, showing a default, a section override, and a student exception.

```yaml
# Course: Introduction to Quantum Physics
PHYS_401:
  # List of all assignments for this course
  assignments:
    - assignment_id: "LAB_01"
      name: "Weekly Lab Reports"
    
      # 1. Base/Default Schedule:
      # This applies to any section not explicitly listed below.
      default_schedule:
        # Pattern for recurring deadlines
        pattern: "weekly"
        day_of_week: "Monday" # Monday, Tuesday, ... Sunday
        time: "10:00 AM"
        # The start date for the first occurrence (optional, but good practice)
        start_date: "2025-09-02" 
      
      # 2. Section-Specific Overrides:
      # A list of specific schedules that override the default_schedule.
      section_schedules:
        - section_id: "SEC_B" # Tuesday lab section
          day_of_week: "Tuesday"
          time: "03:00 PM"
          start_date: "2025-09-03" # First Tuesday
        
        - section_id: "SEC_C" # Online/Distance section with a Friday due date
          day_of_week: "Friday"
          time: "11:59 PM"

      # 3. Individual Student Overrides (The final exception layer):
      # These apply to specific assignments and override ALL section rules.
      student_overrides:
        # Student 'JSmith' gets a full-week extension for the 3rd lab (due 2025-09-16)
        - student_id: "JSmith_8876"
          assignment_occurrence_date: "2025-09-16" 
          new_due_date: "2025-09-23 10:00 AM" # Must be a specific date/time

        # Student 'ASong' for a later lab due 2025-10-01 (in SEC_B)
        - student_id: "ASong_4532"
          assignment_occurrence_date: "2025-10-01" 
          new_due_date: "2025-10-04 03:00 PM"
```

---

### **3. Explanation of Features and Usage**

#### **A. Handling Recurring Deadlines (Weekly Pattern)**

* The system first consults the **`pattern`** key (`weekly` in the example).
* It then uses **`day_of_week`** and **`time`** to determine the weekly recurring due date.
* The script processes this by starting from the **`start_date`** (if provided) and calculating all future occurrences based on the pattern and day/time.

#### **B. Handling Multiple Course Sections**

1. **Look for a Match:** A script first checks the **`section_schedules`** list. If the user's `section_id` matches an entry (e.g., `SEC_B`), the script uses *that specific* `day_of_week` and `time`.
2. **Use Default:** If the `section_id` is *not* found in `section_schedules` (e.g., `SEC_A`), the script falls back to the **`default_schedule`**. This makes data entry efficient, as you only list the exceptions.

#### **C. Handling Individual Student Overrides**

* This is the highest priority exception.
* The `student_overrides` list is checked **after** the recurring date for a student is calculated (based on section/default schedule).
* It requires two keys:
  * **`assignment_occurrence_date`**: This is the *original* date of the assignment being overridden. This is critical because "Lab 1" might recur 15 times, and an override usually applies to only *one* of those occurrences.
  * **`new_due_date`**: The definitive, single date and time for that student's specific deadline.

This hierarchical, plain-text YAML format provides a clear visual hierarchy for human users while offering the structured keys and values needed for reliable, fast processing by scripting code.

Would you like to explore how this format could be extended to handle non-weekly recurring deadlines, such as "bi-weekly" or "monthly"?

You bet\! Here is the complete design for the recurring deadlines data representation, formatted using Markdown.

---

## 🎨 **YAML-Based Deadline Data Representation**

This design uses a hierarchical **YAML (YAML Ain't Markup Language)** structure, which is ideal for balancing **human readability and editability** with **machine parseability**. It moves from the course, down to assignments, then section schedules, and finally, individual student overrides.

### **1. Format Structure and Features**

| Feature                     | YAML Implementation                                                             | Rationale                                                                   |
| :-------------------------- | :------------------------------------------------------------------------------ | :-------------------------------------------------------------------------- |
| **Top Level**         | An outer**dictionary (map)** for the course name/ID.                      | Provides clear context and a single root element.                           |
| **Assignments**       | A list of assignment**objects** under the `assignments` key.            | Allows easy iteration and clear separation of distinct assignments.         |
| **Default Schedule**  | A `default_schedule` object within each assignment.                           | Defines the base pattern (what happens if no section-specific rule exists). |
| **Section Overrides** | A list of `section_schedules` to override the default.                        | Uses the `section_id` as a key to target specific groups.                 |
| **Recurring Pattern** | Uses keys like `day_of_week`, `time`, and `pattern` (e.g., `weekly`).   | Concise, self-documenting pattern definition.                               |
| **Student Overrides** | A `student_overrides` list with explicit `student_id` and new `due_date`. | Handles exceptions clearly at the lowest level of the hierarchy.            |

---

### **2. Example Data File (`deadlines.yaml`)**

This example demonstrates a single course with one assignment, showing a default rule, a section override, and two student exceptions.

```yaml
# Course: Introduction to Quantum Physics
PHYS_401:
  # List of all assignments for this course
  assignments:
    - assignment_id: "LAB_01"
      name: "Weekly Lab Reports"
    
      # 1. Base/Default Schedule:
      # This applies to any section not explicitly listed below (e.g., SEC_A, SEC_D).
      default_schedule:
        # Pattern for recurring deadlines
        pattern: "weekly"
        day_of_week: "Monday" # Monday, Tuesday, ... Sunday
        time: "10:00 AM"
        # The start date for the first occurrence (used to anchor calculations)
        start_date: "2025-09-02" 
      
      # 2. Section-Specific Overrides:
      # A list of specific schedules that override the default_schedule.
      section_schedules:
        - section_id: "SEC_B" # Tuesday lab section
          day_of_week: "Tuesday"
          time: "03:00 PM"
          start_date: "2025-09-03" # First Tuesday
        
        - section_id: "SEC_C" # Online/Distance section with a Friday due date
          day_of_week: "Friday"
          time: "11:59 PM"

      # 3. Individual Student Overrides (The final exception layer):
      # These apply to specific assignments and override ALL section rules.
      student_overrides:
        # Student 'JSmith' gets a full-week extension for the lab originally due on 2025-09-16
        - student_id: "JSmith_8876"
          assignment_occurrence_date: "2025-09-16" 
          new_due_date: "2025-09-23 10:00 AM" # Must be a specific, absolute date/time

        # Student 'ASong' for a later lab due 2025-10-01 (in SEC_B)
        - student_id: "ASong_4532"
          assignment_occurrence_date: "2025-10-01" 
          new_due_date: "2025-10-04 03:00 PM"
```

---

### **3. Explanation of Features and Usage**

#### **A. Handling Recurring Deadlines (Weekly Pattern)**

* The script starts by consulting the **`pattern`** key (`weekly` in the example).
* It then uses **`day_of_week`** and **`time`** to define the weekly recurring schedule.
* The script calculates all occurrences by starting from the **`start_date`** (if provided) and projecting future due dates based on the pattern and time.

#### **B. Handling Multiple Course Sections**

1. **Look for a Match (Highest Priority):** A script first checks the **`section_schedules`** list. If the student's `section_id` matches an entry (e.g., `SEC_B`), the script uses *that specific* schedule.
2. **Use Default (Fallback):** If the `section_id` is *not* found in `section_schedules` (e.g., `SEC_A`), the script automatically falls back to the **`default_schedule`**. This makes the data efficient, as you only list the exceptions to the norm.

#### **C. Handling Individual Student Overrides**

* This is the final, highest-priority exception layer.
* It requires two key pieces of information to ensure accuracy:
  * **`assignment_occurrence_date`**: This is the **original, calculated date** of the specific weekly lab being overridden. This is vital because the override usually applies to only *one* of the recurring due dates.
  * **`new_due_date`**: The definitive, single date and time for that student's specific deadline.

The YAML format's hierarchy and explicit keys provide a robust, clear, and human-friendly way to manage this complex scheduling logic.
