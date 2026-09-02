# LTI 1.3 JWT Claims — Comprehensive Reference

In LTI 1.3, the launch request is fundamentally different. Instead of a signed HTTP POST body, it uses an **OIDC Login Flow** that culminates in an **ID Token** (a signed JSON Web Token or JWT). 

The "parameters" are now expressed as **Claims** within this JWT.

---

## 1. Core OIDC Claims
These are standard JWT claims used for authentication and security.

| Claim | Description |
| :--- | :--- |
| `iss` | **Issuer**: The identifier for the LMS (e.g., `https://canvas.instructure.com`). |
| `sub` | **Subject**: A stable, unique, and opaque identifier for the user. |
| `aud` | **Audience**: The Client ID for your tool as registered in the LMS. |
| `iat` | **Issued At**: Timestamp when the token was generated. |
| `exp` | **Expiration**: Timestamp when the token expires (usually 1-5 minutes). |
| `nonce` | A unique string to prevent replay attacks. |
| `email` | User's email (if privacy settings allow). |
| `name` | User's full name (if privacy settings allow). |
| `given_name` | User's first name. |
| `family_name` | User's last name. |

---

## 2. LTI 1.3 Specific Claims
These claims use the `https://purl.imsglobal.org/spec/lti/claim/` namespace prefix.

### Resource Link Claim (`.../resource_link`)
Identifies the specific link/placement in the platform.
- **`id`**: **(Required)** A stable, opaque ID for the resource link.
- **`title`**: Human-readable title of the link.
- **`description`**: Plain-text description of the link.

### Context Claim (`.../context`)
Describes the environment (e.g., a course) where the launch occurs.
- **`id`**: Unique identifier for the context.
- **`label`**: Short name or code (e.g., "CS101").
- **`title`**: Full title (e.g., "Introduction to Programming").
- **`type`**: Array of URIs (e.g., `["http://purl.imsglobal.org/vocab/lis/v2/course#CourseOffering"]`).

### Tool Platform Claim (`.../tool_platform`)
Contains information about the LMS instance.
- **`guid`**: A unique identifier for the platform instance.
- **`name`**: The name of the platform.
- **`version`**: The version of the platform software.
- **`product_family_code`**: Identifies the LMS product (e.g., `canvas`, `moodle`).
- **`url`**: The base URL of the platform.

### Launch Presentation Claim (`.../launch_presentation`)
UI hints for how the tool should be displayed.
- **`document_target`**: Where the tool should open (`iframe`, `window`, or `overlay`).
- **`return_url`**: The URL to redirect to after the activity.
- **`width`**: Requested width in pixels.
- **`height`**: Requested height in pixels.
- **`locale`**: User's language/locale (e.g., `en-US`).

### LIS Claim (`.../lis`)
Contains institutional data for legacy integration and grade reporting.
- **`person_sourcedid`**: Institutional identifier for the person (e.g., Student ID).
- **`course_offering_sourcedid`**: Institutional identifier for the course offering.
- **`course_section_sourcedid`**: Institutional identifier for the course section.

---

## 3. Roles Claim (`.../roles`)
An array of URIs representing the user's permissions. Common roles include:
- `http://purl.imsglobal.org/vocab/lis/v2/membership#Learner`
- `http://purl.imsglobal.org/vocab/lis/v2/membership#Instructor`
- `http://purl.imsglobal.org/vocab/lis/v2/institution/person#Administrator`

---

## 4. Canvas-Specific LTI 1.3 Claims
Canvas supports **Variable Substitutions** which are mapped into the `https://purl.imsglobal.org/spec/lti/claim/custom` claim.

#### Course & Section Data
- `canvas_course_id`: `$Canvas.course.id`
- `canvas_course_sis_id`: `$Canvas.course.sisSourceId`
- `canvas_section_ids`: `$Canvas.course.sectionIds`

#### User Data
- `canvas_user_id`: `$Canvas.user.id`
- `canvas_user_login_id`: `$Canvas.user.loginId`
- `canvas_user_sis_id`: `$Person.sourcedId`

#### Assignment & Submission
- `canvas_assignment_id`: `$Canvas.assignment.id`
- `canvas_assignment_title`: `$Canvas.assignment.title`
- `canvas_assignment_points_possible`: `$Canvas.assignment.pointsPossible`

### How to Configure in Canvas
In the **Developer Key** configuration, add mappings in the **Custom Fields** box:
```text
course_id=$Canvas.course.id
user_id=$Canvas.user.id
```
These appear in the JWT under the `custom` claim:
```json
"https://purl.imsglobal.org/spec/lti/claim/custom": {
  "course_id": "12345",
  "user_id": "9876"
}
```

**Note:** For a complete list of variables, see the [Canvas Variable Substitutions documentation](https://canvas.instructure.com/doc/api/file.tools_variable_substitutions.html).
