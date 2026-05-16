# PassPort Extension API Implementation Spec

## Overview
Implement the PassPort Protocol v1 in CodeWorkout to allow external Extension Managers (Brokers) to manage student deadline extensions. This includes significant preparatory refactoring of LMS identifiers to ensure robust resource matching.

## Preparatory Requirements

### 1. WorkoutOffering Refactor
- **Goal**: Decouple LMS Instance ID from LTI Assignment ID.
- **Changes**:
  - Add `lms_instance_id` column (integer/bigint) with index.
  - Data migration to split existing `lti_assignment_id` (format: `lms_id-lti_id`).
  - Must be resilient to non-hyphenated values and empty strings.
  - Update all create/update/search logic to use both columns.
  - Enforce unique constraint on `[:lms_instance_id, :lti_assignment_id]`.

### 2. CourseOffering Enhancements
- **Goal**: Store explicit Canvas and LTI context identifiers.
- **Changes**:
  - Add `canvas_course_id` (string) and `lti_context_id` (string) to `CourseOffering` with indexes.
  - Update `LtiController` to persist these values during launch.
  - Enhance assignment lookup logic to utilize these identifiers with the following priority:
    1. `lti_context_id`
    2. `canvas_course_id`
    3. Legacy lookup logic (fallback).

## PassPort API Requirements

### 1. Data Model
**New Model: `ExtensionManager`**
- `id`: Internal ID
- `name`: String (Name of the broker)
- `client_id`: String (Unique, used in headers)
- `client_secret`: String (Used for HMAC signing)
- `broker_base_url`: String (Base URL of the broker)
- `passport_version`: String (Default "1.0")

### 2. API Endpoints

#### A. Registration Endpoint
**Endpoint:** `POST /api/passport/v1/register`
- **Security**: Domain Whitelisting.
  - Verify `broker_base_url` matches an approved domain pattern.
  - Verify request origin matches `broker_base_url`.
- Receives: `broker_base_url`, `passport_version`.
- Action:
  - Create or update `ExtensionManager` record.
  - Generate `client_id` (UUID) and `client_secret` (SecureRandom).
- Responds: `tool_name`, `passport_version`, `endpoints` (extension_handler), `requested_properties`, `credentials` (client_id, client_secret).

#### B. Extension Handler
**Endpoint:** `POST /api/passport/v1/extension`
- **Security**:
  - Verify `X-PassPort-Signature` using HMAC-SHA256 of the body with `client_secret`.
  - Verify `X-PassPort-Timestamp` (within 5 minutes).
  - Verify `X-PassPort-Client-ID` exists.
- **Action**:
  - Identify user via `lti_user_id` or `email`.
  - Identify resource (Workout/WorkoutOffering) via `lti_resource_link_id` or `canvas_assignment_id`.
  - Update student's `due_date` for the assignment.
  - If a later due date is already active, return 409 Conflict.
- Responds: 200 OK or appropriate error code.

#### C. Rollback (Delete Extension)
**Endpoint:** `DELETE /api/passport/v1/extension`
- **Security**: Same as POST.
- **Action**:
  - Revert the extension associated with `request_id`.
- Responds: 200 OK.

### 3. Verification Plan
- Unit tests for `ExtensionManager` model.
- Integration tests for registration and extension endpoints.
- Manual verification using `curl` to simulate Broker requests.

## Status: FINALIZED
