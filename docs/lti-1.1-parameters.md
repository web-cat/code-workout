# LTI 1.1 Launch Parameters — Comprehensive Reference

This document provides a detailed list of the standard parameters sent in an LTI 1.1 launch request (HTTP POST), organized by their functional categories. These categories correspond to the nested objects (subkeys) used in modern LTI 1.3 JWT claims.

## 1. Core LTI Identification
These parameters are required for every LTI 1.1 launch and are used for request validation and versioning.

| Parameter | Description |
| :--- | :--- |
| `lti_message_type` | Always `basic-lti-launch-request`. |
| `lti_version` | Typically `LTI-1p0` (LTI 1.1 is backward compatible with 1.0). |
| `oauth_consumer_key` | The unique identifier for the Tool Consumer (LMS). |
| `oauth_signature` | The OAuth 1.0 HMAC-SHA1 signature. |
| `oauth_signature_method` | Usually `HMAC-SHA1`. |
| `oauth_timestamp` | The timestamp of the request. |
| `oauth_nonce` | A unique string used to prevent replay attacks. |

---

## 2. Resource Link Parameters (`resource_link`)
These parameters identify the specific link or placement in the LMS that initiated the launch.

| Parameter | Description |
| :--- | :--- |
| `resource_link_id` | **(Required)** A unique, opaque ID for the link placement. |
| `resource_link_title` | The plain-text title of the resource link (e.g., "Assignment 1"). |
| `resource_link_description` | A plain-text description of the resource link. |

---

## 3. Context Parameters (`context`)
These describe the environment (typically a course or group) from which the launch originated.

| Parameter | Description |
| :--- | :--- |
| `context_id` | **(Recommended)** A unique identifier for the course/context. |
| `context_label` | A short code for the context (e.g., "CS101"). |
| `context_title` | The full name of the context (e.g., "Intro to Computer Science"). |
| `context_type` | The type of context (e.g., `CourseOffering`, `CourseSection`, `Group`). |

---

## 4. Tool Consumer Parameters (`tool_platform`)
These provide information about the LMS platform instance performing the launch.

| Parameter | Description |
| :--- | :--- |
| `tool_consumer_instance_guid` | A unique identifier for the LMS instance (often a domain or UUID). |
| `tool_consumer_instance_name` | Human-readable name of the institution (e.g., "Virginia Tech"). |
| `tool_consumer_instance_description` | A description of the consumer instance. |
| `tool_consumer_instance_url` | The URL of the consumer instance. |
| `tool_consumer_instance_contact_email` | An administrative contact email for the instance. |
| `tool_consumer_info_product_family_code` | Identifies the LMS product (e.g., `canvas`, `moodle`). |
| `tool_consumer_info_version` | The version of the LMS software. |

---

## 5. User & Roles Information
| Parameter | Description |
| :--- | :--- |
| `user_id` | A unique, opaque identifier for the user. |
| `roles` | A comma-separated list of roles (e.g., `Instructor`, `Learner`). |

---

## 6. Launch Presentation Parameters (`launch_presentation`)
These control how the tool is displayed and how the user returns to the LMS.

| Parameter | Description |
| :--- | :--- |
| `launch_presentation_document_target` | Where the tool opens (`iframe`, `window`, or `overlay`). |
| `launch_presentation_width` | Requested width in pixels. |
| `launch_presentation_height` | Requested height in pixels. |
| `launch_presentation_locale` | The user's language/locale (e.g., `en-US`). |
| `launch_presentation_return_url` | The URL the tool should redirect to when the user is finished. |

---

## 7. LIS Parameters (`lis`)
Used for reporting outcomes (grades) and identifying users/courses via standard LIS identifiers.

| Parameter | Description |
| :--- | :--- |
| `lis_person_name_given` | The user's given (first) name. |
| `lis_person_name_family` | The user's family (last) name. |
| `lis_person_name_full` | The user's full name. |
| `lis_person_contact_email_primary` | The user's primary email address. |
| `lis_person_sourcedid` | Institutional identifier for the person (e.g., Student ID). |
| `lis_course_offering_sourcedid` | Institutional identifier for the course offering. |
| `lis_course_section_sourcedid` | Institutional identifier for the course section. |
| `lis_outcome_service_url` | The URL used to post grades back to the LMS. |
| `lis_result_sourcedid` | Opaque ID used to route the grade to the correct column/student. |

---

## 8. Canvas-Specific Parameters
Canvas provides additional data through **Variable Substitutions** (prefixed with `custom_canvas_`).

#### Course & Context Data
- `custom_canvas_course_id`: Internal numeric ID of the Canvas course.
- `custom_canvas_api_domain`: Domain of the Canvas instance.
- `custom_canvas_enrollment_term_id`: Internal numeric ID of the term.

#### User Data
- `custom_canvas_user_id`: Internal numeric ID of the user.
- `custom_canvas_user_login_id`: User's login ID (email or username).
- `custom_canvas_membership_roles`: Detailed list of user roles in the course.

#### Assignment Data
- `custom_canvas_assignment_id`: Internal numeric ID of the assignment.
- `custom_canvas_assignment_title`: Title of the assignment.
- `custom_canvas_assignment_points_possible`: Total points for the assignment.

**Note:** For a complete list of 80+ Canvas variable substitutions, see the [Canvas Variable Substitutions documentation](https://canvas.instructure.com/doc/api/file.tools_variable_substitutions.html).
