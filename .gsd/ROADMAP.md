# PassPort Extension API Roadmap

## Phase 1: WorkoutOffering Refactor (Wave 1)
- [x] Add `lms_instance_id` to `WorkoutOffering`
- [x] Data migration: Split `lti_assignment_id`
- [x] Update controller/model logic for split IDs
- [x] Verify creation/lookup logic

## Phase 2: CourseOffering Enhancements (Wave 2)
- [ ] Add `canvas_course_id` and `lti_context_id` to `CourseOffering`
- [ ] Update `LtiController` to store IDs on launch
- [ ] Update lookup logic to use new fields
- [ ] Verify persistence and lookup

## Phase 3: PassPort Foundation (Wave 3)
- [ ] Create `ExtensionManager` model and migration
- [ ] Implement credential generation logic
- [ ] Add basic routes for registration and extension

## Phase 4: PassPort Implementation (Wave 4)
- [ ] Implement `register` endpoint
- [ ] Implement `extension` endpoint with signature verification
- [ ] Implement `rollback` (DELETE) logic

## Phase 5: Integration & Final Verification (Wave 5)
- [ ] Full end-to-end testing of extension flow
- [ ] Manual verification with `curl`
