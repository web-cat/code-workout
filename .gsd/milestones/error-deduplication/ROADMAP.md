# Error Table Deduplication & Aggregation Roadmap

## Wave 1: Database Migration & Backfill
- [x] Create migration `db/migrate/20261017120000_add_fingerprint_and_count_to_errors.rb`
  - Add `fingerprint` (`varchar(64)` indexed)
  - Add `count` (`integer, default: 1, null: false` indexed)
  - Add `last_seen_at` (`datetime`)
  - Backfill existing rows with Ruby SHA-256 fingerprinting and group deduplication
  - Support reversible rollback in `down`
- [x] Run migration using `rvm 2.7.0 do bundle exec rake db:migrate`
- [x] Verify `schema.rb` and test rollback/re-migration

## Wave 2: Model Deduplication & Bugfix
- [x] Fix `ActiveModel::MissingAttributeError: can't write unknown attribute user_agent` in `ExceptionHandler::Exception`
  - Associate `belongs_to :user_agent, optional: true`
  - Add virtual setter `user_agent=` matching `Error`
  - Update initialization attribute assignment from `self[type]=` to `send("#{type}=", ...)`
- [x] Implement deterministic `generate_fingerprint` in `ExceptionHandler::Exception` and `Error`
- [x] Implement `aggregate_duplicate_errors` before-save callback
  - Find existing record by fingerprint
  - Update count, last_seen_at, and latest context attributes
  - Abort insert via `throw :abort` when duplicate exists
- [x] Ensure `Error` model includes matching associations, attributes, and fingerprint helper via `ErrorAggregation` concern

## Wave 3: ActiveAdmin Dashboard Updates
- [x] Update `app/admin/error.rb`
  - Set default sort order to `:count_desc`
  - Configure index table columns: `:count`, `:class_name`, `:message`, `:target` ("Last URL"), `:last_seen_at`, `:created_at`
  - Enhance show page to display `:count`, `:fingerprint`, and `:last_seen_at`
  - Configure sidebar filters for `:count`, `:class_name`, `:last_seen_at`, `:created_at`

## Wave 4: Automated Testing & Spec Coverage
- [x] Verify existing test suite: run `rvm 2.7.0 do bundle exec rspec spec/models/exception_handler_spec.rb` to confirm all 19 specs pass
- [x] Add unit tests for fingerprinting and aggregation in `spec/models/exception_handler_spec.rb` and `spec/models/error_spec.rb`:
  - Test fingerprint generation normalizes dynamic memory addresses
  - Test initial error creation sets `count = 1`, `last_seen_at`, and `fingerprint`
  - Test duplicate error does not insert a new row, increments `count`, and updates `last_seen_at`
  - Test user agent association transparent resolution
- [x] Verify ActiveAdmin loading and routes

## Wave 5: End-to-End Verification & Documentation
- [x] Run full test suites (61 examples, 0 failures across error and user-agent models and controllers)
- [x] Test exception handling in Rails environment
- [x] Update `.gsd/STATE.md` with execution summary and verification evidence
- [x] Create walkthrough artifact documenting changes
