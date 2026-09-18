# IP Access Restrictions for Workout Offerings Spec

## Overview
Add support for IP access restrictions to workout offerings in CodeWorkout. Instructors can specify allowed IP addresses, subnet masks (CIDR), and wildcard patterns in the deadlines YAML on the workout edit form, either globally for all offerings or on a per-offering basis. Individual student extensions can override offering IP restrictions or completely remove restrictions (`ips: any`). Restrictions are strictly enforced when viewing a workout show page, loading an exercise practice page, and submitting an attempt.

---

## 1. Functional Requirements

### 1.1 IP Format & Pattern Support (`IpAccessFilter`)
The system must support the most widely used network location specification schemes:
- **Individual IP addresses**: Both IPv4 (`192.168.1.50`, `127.0.0.1`) and IPv6 (`::1`, `2001:db8::1`).
- **CIDR Subnet Masks**: `192.168.1.0/24`, `10.0.0.0/8`, `2001:db8::/32`.
- **Netmask Notation**: `192.168.1.0/255.255.255.0`.
- **Wildcard / Glob Patterns**: `192.168.1.*`, `128.173.*.*`, `198.82.*`.
- **Delimited Lists**: Comma, space, semicolon, or newline-delimited strings, or YAML array format.
- **Special Keywords**:
  - `any`, `all`, `*`, `unrestricted`: Allows all IPs (no restriction).
  - `none`: Blocks all IPs.
  - `nil` / blank: Unrestricted.
- Resilient to whitespace and malformed inputs (fails closed/logs warning without 500 error).

### 1.2 Deadlines YAML Specification (Workout Edit Form)
Instructors manage IP restrictions directly within the Offerings and Extensions YAML:
- **All Offerings (Top-Level Default)**:
  ```yaml
  ips: 128.173.*.*, 198.82.0.0/16
  sections:
    - section: CS 101 Section A
      due: 2026-09-15 11:59 PM
  ```
  Aliases supported: `ips`, `allowed_ips`, `ip_restrictions`.
- **Per-Offering Override**:
  ```yaml
  sections:
    - section: CS 101 Section A
      due: 2026-09-15 11:59 PM
      ips: 192.168.1.0/24
  ```
- **Student Extension Overrides**:
  ```yaml
  extensions:
    - due: 2026-09-20 11:59 PM
      ips: any   # completely removes IP restrictions for these students
      students:
        - Alice Smith <asmith@example.edu>
  ```
  Extensions can specify custom IP rules or `any` to allow access from any network location.
- **YAML Round-Trip Serialization**:
  When editing a workout, `serialize_workout_offerings_to_yaml` must preserve and render `ips:` cleanly (at top-level when uniform, or per-section when divergent, and in extension groups).

### 1.3 Enforcement Points, Diagnostics & Activity Logging
Enforcement is evaluated via `workout_offering.ip_allowed?(request.remote_ip, user)`:
1. **Workout Show Page** (`WorkoutOfferingsController#show`, `WorkoutsController#show`, `course_workout_show`):
   - If IP is not permitted, log an `ActivityLog` entry (`activity: 'workout_view_ip_blocked'`).
   - Display diagnostic: `"This workout cannot be accessed from your network location (#{request.remote_ip})."`
   - Renders `workout_offerings/error.html.haml` (or `lti/error.html.haml` if LTI launch).
2. **Exercise Practice Page Load** (`WorkoutOfferingsController#practice`, `ExercisesController#practice`):
   - If IP is not permitted, log an `ActivityLog` entry (`activity: 'practice_view_ip_blocked'`).
   - Intercept before rendering practice view or creating initial score.
   - Render diagnostic error page.
3. **Attempt Submission** (`ExercisesController#evaluate`):
   - If IP is not permitted, log an `ActivityLog` entry (`activity: 'attempt_ip_blocked'`).
   - Intercept before creating attempt, evaluating code, or scoring.
   - Redirect to the workout offering error page.
   - Supports JS redirect (`window.location = ...`) for AJAX submissions, HTML redirect, and JSON error response.
4. **Staff/Admin Exemption**:
   - Course staff (`course_offering.is_staff?(user)`) and admins (`user.global_role.is_admin?`) bypass IP checks.

---

## 2. Database Schema Changes
- Add `allowed_ips` (`text`, nullable) to `workout_offerings`.
- Add `allowed_ips` (`text`, nullable) to `student_extensions`.
- Add `last_ip_address` (`string`, nullable) to `workout_scores` for fast-path IP validation caching.
- Migration: `db/migrate/20260902153000_add_allowed_ips_to_workout_offerings_and_student_extensions.rb`.

---

## 3. Verification & Testing
- Model unit tests for `IpAccessFilter` covering all IP pattern variations.
- Unit tests for `WorkoutOffering#ip_allowed?` and `StudentExtension#allowed_ips` overrides.
- Controller integration tests for `WorkoutOfferingsController`, `ExercisesController#practice`, `ExercisesController#evaluate`, and `WorkoutsController` YAML round-trips.
- Verification that staff/admin can access regardless of IP.
- Verification that student extension with `ips: any` grants access to previously restricted IP.

---

# Browser Agent Requirements for Workout Offerings Spec

## 4. Overview
Add support for optional browser agent requirements (e.g. requiring the use of LockDown Browser, Secure Exam Browser, etc., by confirming their user agent markers) to workout offerings in CodeWorkout. Instructors can specify allowed/required browsers (markers, substrings, patterns, or regex) in the deadlines YAML on the workout edit form, globally for all offerings or per-offering. Individual student extensions can override offering browser restrictions or completely remove restrictions (`browsers: any`). Restrictions are strictly enforced when viewing a workout show page, loading an exercise practice page, and submitting an attempt.

---

## 5. Functional Requirements

### 5.1 Browser Agent Format & Pattern Support (`UserAgentAccessFilter`)
- **Keywords**:
  - `any`, `all`, `*`, `unrestricted`: Allows all user agents (no restriction).
  - `none`: Blocks all browsers.
  - `nil` / blank: Unrestricted.
- **Substring Matching**: Case-insensitive substring match (e.g. `LockDown Browser`, `SEB`, `Respondus`, `SecureExamBrowser`).
- **Wildcard / Glob Matching**: Wildcard expressions like `*LockDown*`, `*SEB*` via `File.fnmatch?`.
- **Regex Matching**: Expressions enclosed in `/.../`.
- **Delimited Lists**: Comma, semicolon, newline, or array formats.

### 5.2 Deadlines YAML Specification (Workout Edit Form)
- **All Offerings (Top-Level Default)**:
  ```yaml
  browsers: LockDown Browser, SEB
  sections:
    - section: CS 101 Section A
      due: 2026-09-15 11:59 PM
  ```
  Aliases supported: `browsers`, `user_agents`, `allowed_user_agents`.
- **Per-Offering Override**:
  ```yaml
  sections:
    - section: CS 101 Section A
      due: 2026-09-15 11:59 PM
      browsers: SEB
  ```
- **Student Extension Overrides**:
  ```yaml
  extensions:
    - due: 2026-09-20 11:59 PM
      browsers: any   # completely removes browser requirements for these students
      students:
        - Alice Smith <asmith@example.edu>
  ```
- **YAML Round-Trip Serialization**:
  - Uses `browsers:` as standard key.
  - Output at top-level when all offerings share identical non-blank rules.
  - Output per-section when rules differ.
  - Output under extensions when extensions define custom browser rules.

### 5.3 Enforcement Points, Diagnostics & Activity Logging
Enforcement is evaluated via `workout_offering.user_agent_allowed?(request.user_agent, user, workout_score)`:
1. **Workout Show Page** (`WorkoutOfferingsController#show`, `WorkoutsController#show`):
   - If user agent is not allowed:
     - Log `workout_view_user_agent_blocked` to `ActivityLog`.
     - Display diagnostic: `"This workout requires a specific browser (such as LockDown Browser or Secure Exam Browser) and cannot be accessed from your current browser."`
     - Render `workout_offerings/error.html.haml` (or `lti/error.html.haml`).
2. **Exercise Practice Page Load** (`WorkoutOfferingsController#practice`, `ExercisesController#practice`):
   - If user agent is not allowed:
     - Log `practice_view_user_agent_blocked` to `ActivityLog`.
     - Render diagnostic error page.
3. **Attempt Submission** (`ExercisesController#evaluate`):
   - If user agent is not allowed:
     - Log `attempt_user_agent_blocked` to `ActivityLog`.
     - Abort attempt evaluation (no attempt created, no scoring changes).
     - Redirect to the workout offering error page (HTML/JS/JSON).
4. **Staff/Admin Exemption**:
   - Course staff within the course offering context (`course_offering.is_staff?(user)`) and global administrators (`user.global_role.is_admin?`) bypass restrictions. Other global roles (e.g. global instructors not enrolled in the course offering) are not exempt.
5. **Fast-Path Caching**:
   - `workout_score.last_user_agent` short-circuits evaluation when matching the request user agent.

---

## 6. Database Schema Changes
- Add `allowed_user_agents` (`text`, nullable) to `workout_offerings`.
- Add `allowed_user_agents` (`text`, nullable) to `student_extensions`.
- Add `last_user_agent` (`text`, nullable) to `workout_scores`.
- Add `user_agent` (`text`, nullable) to `activity_logs`.
- Migration: `db/migrate/20260902200000_add_allowed_user_agents_to_workout_offerings_and_student_extensions.rb`.

---

## Status: FINALIZED
