# Technical Debt & Concerns

> Comprehensive list of technical debt items (TODO, FIXME, etc.) found across the `app/` and `lib/` directories, organized by component.

## Controllers

| File | Concern | Recommended Action |
|------|---------|--------------------|
| `course_offerings_controller.rb` | (L132) Sub-optimal logic placement; (L228) Needs to read an actual CSV. | Refactor logic to a service object; Update CSV parsing logic to accept standard CSV files. |
| `courses_controller.rb` | (L224) Unclear purpose of method and `Course.search`. | Analyze the search mechanism, document the method, or remove it if unused. |
| `exercises_controller.rb` | (L384, L864+) Missing JSON support; limited to single prompts; assumes no multi-choice; temporary logic scattered. | Refactor the assessment logic to scale for multi-prompt and multi-choice questions. Re-enable `@explain` and `@exercise_feedback`. Refine experience calculation. |
| `lti_controller.rb` | (L161) Consider creating new terms. | Implement term auto-creation or proper term mapping during LTI launch. |
| `workout_offerings_controller.rb` | (L87) Needs to verify `ex1` belongs to the workout. | Add a validation before processing to ensure the exercise is part of the current workout. |
| `workouts_controller.rb` | (L68) Logic duplicated from `exercises_controller`. | Extract the duplicated code into a shared module or service class. |

## Models

| File | Concern | Recommended Action |
|------|---------|--------------------|
| `ability.rb` | (L75, L110) Permissions are too broad and not role-based. | Refactor Cancancan abilities to check specific role-based permissions instead of broad `manage` blocks. |
| `coding_prompt.rb` | (L138-139) Auto-guess method/class name from starter code. | Build a parser utility to infer signatures directly from the wrapper/starter code. |
| `course_offering.rb` | (L54, L78) Broken scope; deprecate `display_*` method. | Use the corrected scope `user.managed_course_offerings`. Refactor views to use the correct display helpers. |
| `exercise_version.rb` | (L287+) Move methods to `multiple_choice_prompt`; broken scaling logic. | Move multi-choice specific behavior to the correct prompt subclass. Decide firmly on negative scoring policy. |
| `exercise.rb` | (L215) Logic doesn't belong in this class. | Extract misplaced logic into a helper, service, or appropriate related model. |
| `irt_data.rb` | (L37) Need incremental difficulty/discrimination updates. | Implement an async job to recalculate IRT data periodically based on new attempts. |
| `prompt.rb` | (L54+) Missing `Attempt` and `Hint` models; missing score calculation. | Architect new AR models for `Attempt` and `Hint`. Shift scoring responsibilities appropriately. |
| `resource_file.rb` | (L78-114) Unclosed tempfiles; defunct CarrierWave code. | Clean up old methods. Ensure tempfiles are unlinked in `ensure` blocks. |
| `test_case.rb` | (L271) Nested parentheses handling is flawed. | Use a proper regex or string parser for nested grouping rather than simple search. |
| `uploaded_exercise.rb` | (L104+) Hardcoded logic for "imported" strings, difficulty, stats. | Parse these fields out of the incoming file payload (like standard PEML) instead of hardcoding. |
| `uploaded_roster.rb` | (L216) Email address detection needs to be smarter. | Use regex or a mail parsing library to identify valid email addresses from upload rows. |
| `workout.rb` | (L96-204) Properties belong on the workout; refactor to use workout score. | Move methods to correct models and rely on the `workout_score` relation instead of raw workout calculations. |
| `workout_offering.rb` | (L186) "Broken kludge" | Needs architectural review to replace the hacky logic with a robust implementation. |
| `workout_score.rb` | (L140-207) Misnamed method used elsewhere; confusing ("???") logic. | Rename the method with appropriate aliasing. Trace and clarify the confusing logic segments. |

## Background Jobs & Utilities

| File | Concern | Recommended Action |
|------|---------|--------------------|
| `code_worker.rb` | (L115) Need C++ error message line number extraction. | Add regex patterns specifically designed for `g++` compilation output. |
| `peml_parsing_util.rb` | (L74-228) Lacking error handling/messages for missing tests, bad URLs, etc. | Implement robust exceptions or validation accumulation arrays to report parsing errors back to the user instead of failing silently. |

## Views

| File | Concern | Recommended Action |
|------|---------|--------------------|
| `courses/_tab_exercises.html.haml` | (L3) Broken path; should use helper. | Replace hardcoded view logic with proper Rails route helpers. |
| `courses/_tab_grades.html.haml` | (L1) Funky logic. | Refactor complex view logic back into the controller or a presenter/decorator. |
| `users/calc_performance.html.haml` | (L39) Dummy progress bars. | Wire progress bars to actual database metrics. |
| `workouts/_exercise_workout_fields.html.haml` | (L12) Ordering specification missing. | Restore the drag-and-drop or ordering input fields. |
