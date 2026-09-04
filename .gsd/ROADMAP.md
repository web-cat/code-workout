# IP Access Restrictions Roadmap

## Phase 1: Database & IP Filtering Core (Wave 1)
- [x] Create migration adding `allowed_ips` to `workout_offerings` and `student_extensions`, and `last_ip_address` to `workout_scores`
- [x] Run migration using `rvm 2.7.0 do bundle exec rake db:migrate`
- [x] Implement `IpAccessFilter` supporting single IPs, CIDR, wildcards, lists, and `any`/`none`
- [x] Write unit specs for `IpAccessFilter`
- [x] Add `allowed_ips_for(user)` and `ip_allowed?(client_ip, user, workout_score)` to `WorkoutOffering`
- [x] Add `allowed_ips` handling to `StudentExtension`
- [x] Write unit specs for `WorkoutOffering#ip_allowed?` and student extension overrides, including `last_ip_address` short-circuiting

## Phase 2: Deadlines YAML Parsing & Serialization (Wave 2)
- [x] Update `WorkoutsController#create_or_update_offerings` to parse top-level, per-section, and extension `ips`
- [x] Update `Workout#add_workout_offerings` to assign `allowed_ips`
- [x] Update `WorkoutsController#serialize_workout_offerings_to_yaml` to serialize `ips`
- [x] Update help documentation in `app/views/help/specifying_due_dates.html.haml`
- [x] Add controller specs for YAML parsing and serialization with IP restrictions

## Phase 3: Access Enforcement, Diagnostics & Activity Logging (Wave 3)
- [x] Add `:error` action and route for workout offerings (`workout_offerings#error`)
- [x] Create error diagnostic view `app/views/workout_offerings/error.html.haml`
- [x] Enforce IP restrictions in `WorkoutOfferingsController#show` and log `workout_view_ip_blocked` in ActivityLog
- [x] Enforce IP restrictions in `WorkoutOfferingsController#practice` and log `practice_view_ip_blocked` in ActivityLog
- [x] Enforce IP restrictions in `WorkoutsController#show` and log `workout_view_ip_blocked`
- [x] Enforce IP restrictions in `ExercisesController#practice` and log `practice_view_ip_blocked`
- [x] Enforce IP restrictions in `ExercisesController#evaluate` and log `attempt_ip_blocked`, aborting evaluation and redirecting to error page
- [x] Add controller specs for IP restriction enforcement across all actions

## Phase 4: Final Verification & Documentation (Wave 4)
- [x] Run full test suites
- [x] Create walkthrough artifact documenting changes and verification evidence

# Browser Agent Requirements Roadmap

## Phase 5: Database & UserAgentAccessFilter Core (Wave 5)
- [x] Create migration adding `allowed_user_agents` to `workout_offerings` and `student_extensions`, `last_user_agent` to `workout_scores`, and `user_agent` to `activity_logs`
- [x] Run migration using `rvm 2.7.0 do bundle exec rake db:migrate`
- [x] Implement `UserAgentAccessFilter` supporting substrings, wildcards, regex, and keywords (`any`/`none`)
- [x] Write unit specs for `UserAgentAccessFilter`
- [x] Add `allowed_user_agents_for(user)` and `user_agent_allowed?(user_agent, user, workout_score)` to `WorkoutOffering` (with course staff enrollment and admin bypass, plus `last_user_agent` fast-path caching)
- [x] Add `allowed_user_agents` handling to `StudentExtension` and `Workout#add_workout_offerings`
- [x] Write unit specs for `WorkoutOffering#user_agent_allowed?`

## Phase 6: Deadlines YAML Parsing & Serialization (Wave 6)
- [x] Update `WorkoutsController#create_or_update_offerings` to parse `browsers:` / `user_agents:`
- [x] Update `WorkoutsController#serialize_workout_offerings_to_yaml` to serialize `browsers:`
- [x] Update help documentation in `app/views/help/specifying_due_dates.html.haml`
- [x] Add controller specs for YAML parsing and serialization of browser requirements

## Phase 7: Access Enforcement, Diagnostics & Activity Logging (Wave 7)
- [x] Enforce user agent restrictions in `WorkoutOfferingsController#show` and `WorkoutsController#show`
- [x] Enforce user agent restrictions in `WorkoutOfferingsController#practice` and `ExercisesController#practice`
- [x] Enforce user agent restrictions in `ExercisesController#evaluate` and redirect to error page
- [x] Store `user_agent` in `ActivityLog` entries and log blocked events (`workout_view_user_agent_blocked`, `practice_view_user_agent_blocked`, `attempt_user_agent_blocked`)
- [x] Update `app/views/workout_offerings/activity_log.html.haml` with browser blocked descriptions
- [x] Add controller specs for browser access enforcement and activity logging

## Phase 8: Final Verification & Integration (Wave 8)
- [x] Run full test suite across all models and controllers
- [x] Update walkthrough artifact with browser agent verification results
