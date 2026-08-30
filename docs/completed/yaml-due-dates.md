# Specification: YAML-Based Workout Date Management

This document specifies the behavior for a YAML-based interface used to manage workout availability dates and student extensions. The system supports absolute dates, flexible relative offsets, and specialized terminology for clarity.

---

## 1. YAML Schema

The YAML structure consists of two top-level keys:

- `sections`: A list of objects representing course sections (offerings).
- `extensions`: A list of objects representing overrides for specific students.

### Field Definitions:
- `section` (Sections only): String matching the course offering label.
- `due` (Required): The primary due date (soft deadline).
- `from` (Optional): The opening date when the workout becomes visible.
- `until` (Optional): The hard deadline after which submissions are blocked.
- `students` (Extensions only): A list of student identifiers (Email or "Name <email>").

---

## 2. Parsing Specification

### A. General Keyword Handling
The following strings are treated as `null` (no setting) across all date fields:
- `""` (empty string), `null`, `nil`, `empty`

### B. "From" (Opening Date) Keywords
- `always`, `unlimited`: Specifically for the `from` field, these indicate immediate availability (represented as `null` in the backend).

### C. Relative Offset Parsing
Offsets are calculated relative to the `due` date in the same block.

- **Regex**: `/^([+-]?)\s*(\d*\.?\d+)\s*([a-z]+)$/i`
- **Units Supported**: 
  - Minutes: `m`, `min`, `mins`, `minute`, `minutes`
  - Hours: `h`, `hr`, `hrs`, `hour`, `hours`
  - Days: `d`, `day`, `days`
  - Weeks: `w`, `wk`, `wks`, `week`, `weeks`
- **Flexibility**: Supports floating point numbers (e.g., `1.5 hours`) and flexible whitespace between sign/number and number/unit.

### D. Directional Validation
1. **`from` (Opening Date)**:
   - Must be negative. 
   - A leading `+` sign results in a validation error.
   - If no sign is provided (e.g., `1 day`), it is interpreted as a **negative** offset (`-1 day`).
2. **`until` (Hard Deadline)**:
   - Must be non-negative.
   - A leading `-` sign results in a validation error.
   - If no sign is provided (e.g., `3 days`), it is interpreted as a **positive** offset (`+3 days`).

---

## 3. Rendering Specification

When loading the form, the system must standardize the YAML representation using the following logic:

### A. Fallback to Relative Offsets
For `from` and `until` fields, use relative offsets if the interval meets these criteria:
1. **Exact Days**: If the interval is an exact integral number of days, render as a relative day offset.
2. **Recent Hours**: If the interval is < 24 hours and is an exact integral number of hours, render as a relative hour offset.
3. **Recent Minutes**: If the interval is < 181 minutes and is an exact integral number of minutes, render as a relative minute offset.
4. **Otherwise**: Fallback to an absolute date/time string formatted in the user's timezone.

### B. Standardized Relative Format
- Always include the sign (`+` or `-`).
- No whitespace between sign and number (e.g., `+3`).
- Exactly one space between number and unit (e.g., `+3 days`).
- Use full unit names (`minutes`, `hours`, `days`, `weeks`).
- Correct singular/plural form based on value (e.g., `+1 day` vs `+2 days`).
- Trim trailing zeros for floats (e.g., `1.5` instead of `1.50`, `3` instead of `3.0`).

### C. Default Values for Rendering
- **Missing `from`**: Render as `always`.
- **Missing `until`**: Render as `+0 minutes`.

---

## 4. UI & Toolbar Specification

### A. Cursor Locking
To prevent data insertion at the wrong location when users interact with modals or pickers:
1. When a toolbar button is clicked, immediately capture the current cursor position (`selectionStart`) in the text area.
2. Store this as the "locked" position.
3. Any data returned from a modal (Student Search) or picker (Date Picker) must be inserted at this locked position.

### B. Toolbar Actions
1. **Select Date**: Opens a date/time picker. On confirmation, inserts the formatted absolute date at the locked position.
2. **+ Add Student**: Opens a student search modal. On selection, inserts `"Name <email>"` at the locked position.
3. **+ Course Offering**: Inserts a new section template block. This insertion should automatically happen just before the `extensions:` key if it exists.

### C. Interactive Validation
If a toolbar button is clicked without a prior focus/click in the text area (no cursor position established):
1. Display a transient popover (tooltip-style) on the button with the message "Select an insertion point first."
2. Do not open the modal or picker.

---

## 5. Example YAML

```yaml
sections:
  - section: CS 101 Section A
    due: 2025-09-15 11:59 PM
    from: always             # Rendered from null
    until: +0 minutes        # Rendered from null or identical to due
  - section: CS 101 Section B
    due: 2025-09-16 11:59 PM
    from: -3 days            # Rendered from exact interval
    until: +12 hours         # Rendered from exact interval < 24h

extensions:
  - due: 2025-09-20 05:00 PM  # Absolute date fallback
    from: always
    until: +1 day
    students:
      - John Doe <jdoe@example.edu>
      - Jane Smith <jsmith@example.edu>
```
