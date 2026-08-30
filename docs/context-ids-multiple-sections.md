# Canvas LTI Launch — Multiple Sections & Automatic Parameters

When Canvas cross-lists sections into a single course site, multiple sections are effectively "moved" into a single parent course shell. This has a significant impact on how LTI parameters are populated.

---

### 1. The `context_id` Behavior
In both LTI 1.1 and LTI 1.3, the `context_id` (and the `context` claim) identifies the **Canvas Course Site** (the parent shell).
- **The Problem:** Because all cross-listed sections share the same course site, every user in the course—regardless of which section they were originally in—will receive the **same `context_id`**.
- **Result:** An external tool cannot use `context_id` alone to determine which section a user is enrolled in.

---

### 2. Automatic Canvas Parameters (LTI 1.1)
Beyond the standard LTI fields, Canvas automatically provides several extension parameters (prefixed with `ext_`) during an LTI 1.1 launch, especially when launched from an assignment.

| Parameter | Description |
| :--- | :--- |
| `ext_lti_assignment_id` | **(Automatic)** A unique UUID-like identifier for the specific assignment in Canvas. This is the primary key for matching assignments. |
| `ext_outcome_data_values_accepted` | Comma-separated list of formats Canvas will accept for grade passback (e.g., `url,text`). |
| `ext_outcome_result_total_score_accepted` | Boolean indicating if the LMS accepts a total score. |
| `ext_roles` | A more detailed list of Canvas roles than the standard `roles` parameter. |
| `ext_canvas_course_navigation_placement_url` | Provided if the launch originates from the Course Navigation menu. |

---

### 3. How to Identify Sections (Variable Substitutions)
To determine the specific section(s) for a user, you must use **Variable Substitutions**. These are NOT sent automatically; they must be configured in the "Custom Fields" of your tool.

#### LTI 1.1 Custom Fields
Add these to your tool configuration to receive them as `custom_` parameters:
- `custom_canvas_course_id=$Canvas.course.id`
- `custom_canvas_user_id=$Canvas.user.id`
- `custom_canvas_assignment_id=$Canvas.assignment.id`
- `custom_section_ids=$Canvas.course.sectionIds`
- `custom_section_sis_ids=$Canvas.course.sectionSisSourceIds`

#### LTI 1.3 Custom Fields
Configured in the Developer Key, these appear in the `custom` claim:
- `canvas_course_id=$Canvas.course.id`
- `section_ids=$Canvas.course.sectionIds`
- `section_names=$com.instructure.User.sectionNames`

---

### 4. Summary Table: Cross-listing Logic
| Field / Claim | Value in Cross-listed Course |
| :--- | :--- |
| `context_id` / `context[id]` | The **Parent Course ID** (shared by everyone). |
| `custom_canvas_course_id` | The **Parent Course ID** (if configured). |
| `ext_lti_assignment_id` | Unique to the **Assignment**, regardless of section. |
| `$Canvas.course.sectionIds` | The **specific IDs** of the section(s) the user belongs to. |
| `lis_course_section_sourcedid` | Typically the SIS ID of the **first section** (unreliable if in multiple). |

---

### Conclusion: Can a tool determine the section?
**Yes, but it requires explicit configuration.**
1. **Standard LTI:** Identifies only the course shell.
2. **Custom Parameters:** You must map `$Canvas.course.sectionIds` to a custom field.
3. **Multiple Enrollments:** If a student is in multiple sections (e.g., lecture and lab), `$Canvas.course.sectionIds` returns a **comma-separated list**.
4. **Full Roster Access:** If the tool needs to know about all sections (including empty ones), it must use the **Canvas REST API** (`GET /api/v1/courses/:course_id/sections`).
