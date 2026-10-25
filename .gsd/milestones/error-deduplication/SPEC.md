# Error Table Deduplication & Aggregation Spec

## Overview
Refactor run-time error tracking in CodeWorkout to aggregate identical exceptions into a single row in the `errors` table using deterministic SHA-256 fingerprinting, an occurrence counter (`count`), and a timestamp (`last_seen_at`). This replaces the unbounded row-per-occurrence pattern that causes table bloat, alert fatigue, and triage difficulties, while enabling instant prioritization by error frequency in the ActiveAdmin dashboard.

---

## 1. Functional Requirements

### 1.1 Schema Changes & Data Backfill
1. **New Columns on `errors` table**:
   - `fingerprint`: `varchar(64)`, indexed.
   - `count`: `integer`, `default: 1`, `null: false`, indexed.
   - `last_seen_at`: `datetime`.
2. **Safe Migration Backfill**:
   - For all existing rows in `errors`:
     - Compute the SHA-256 fingerprint from `class_name`, normalized `message`, and top 3 lines of `trace`.
     - Group existing records by fingerprint.
     - For each group with duplicate rows:
       - Retain the primary record (earliest created).
       - Update the primary record's `count` to the group size.
       - Update `last_seen_at` to the group's maximum `updated_at || created_at`.
       - Delete the duplicate records.
     - For unique records, set `count = 1`, `fingerprint = <computed>`, and `last_seen_at = updated_at || created_at`.
   - Migration must be fully reversible (`down` method restores previous schema state).
   - Use Ruby's `Digest::SHA256` to prevent database-level collation mismatch issues (such as MariaDB 11 `SHA2` collation mismatch).

### 1.2 Model & Exception Handler Integration (`ExceptionHandler::Exception` and `Error`)
1. **User Agent Attribute Compatibility Fix**:
   - Resolve `ActiveModel::MissingAttributeError: can't write unknown attribute user_agent` in `ExceptionHandler::Exception`:
     - Associate `belongs_to :user_agent, optional: true`.
     - Add transparent virtual setter `def user_agent=(val)` matching `Error` model.
     - Update initialization from `self[type] = eval type.to_s` to `send("#{type}=", eval(type.to_s))` to properly route virtual attributes.
2. **Deterministic Fingerprint Generator**:
   - Method `generate_fingerprint` in `ExceptionHandler::Exception` and `Error`:
     - Strips dynamic hex memory addresses (`0x[0-9a-fA-F]+`) from `message`.
     - Truncates trace to the top 3 lines (ignoring variable deep stack frames).
     - Returns `Digest::SHA256.hexdigest("#{class_name}:#{sanitized_msg}:#{top_trace}")`.
3. **Deduplication Callback (`before_save :aggregate_duplicate_errors`)**:
   - Populates `fingerprint ||= generate_fingerprint`.
   - Populates `last_seen_at ||= Time.current`.
   - Checks if an existing record with the same fingerprint exists in `errors`:
     - If an existing record exists (with `id != self.id`):
       - Updates the existing record in-place:
         - `count: existing.count + 1`
         - `last_seen_at: Time.current`
         - Updates latest request context: `target`, `referrer`, `params`, `user_agent_id`
       - Executes `throw :abort` to stop saving the new record, preventing duplicate insertion.
     - If no existing record exists:
       - Ensures `self.count ||= 1`.

### 1.3 ActiveAdmin Dashboard Updates (`app/admin/error.rb`)
1. **Default Sort Order**:
   - Configure default ordering to `:count_desc` so the most frequent errors appear at the top.
2. **Index Columns**:
   - `:count` (sortable by `:count`, styled for visibility).
   - `:class_name` (sortable).
   - `:message` (truncated with link to show page).
   - `Last URL` (`:target`).
   - `:last_seen_at` (sortable).
   - `:created_at` (sortable, labeled "First seen").
3. **Show Page & Filters**:
   - Display `count`, `fingerprint`, and `last_seen_at`.
   - Add filters for `class_name`, `count`, `last_seen_at`, and `created_at`.

---

## 2. Verification Criteria
1. **Existing Specs Pass**: All 19 examples in `spec/models/exception_handler_spec.rb` pass without `MissingAttributeError`.
2. **New Specs Pass**:
   - Identical exceptions generate the identical fingerprint.
   - Exceptions with different memory addresses generate the same fingerprint.
   - Saving a duplicate exception does not increase total error count in the database.
   - Duplicate exception increases `count` by 1 and updates `last_seen_at`.
   - ActiveAdmin configuration loads and functions correctly.
3. **Migration Verification**:
   - `rvm 2.7.0 do bundle exec rake db:migrate` succeeds.
   - `schema.rb` reflects new columns and indexes.
   - Rollback and re-migration execute cleanly.
