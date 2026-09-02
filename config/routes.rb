# == Route Map
#
#                                          Prefix Verb     URI Pattern                                                                                                 Controller#Action
#                                            root GET      /                                                                                                           home#index
#                        api_passport_v1_register POST     /api/passport/v1/register(.:format)                                                                         api/passport/v1/registration#register
#                       api_passport_v1_extension POST     /api/passport/v1/extension(.:format)                                                                        api/passport/v1/extension#create
#                                                 DELETE   /api/passport/v1/extension(.:format)                                                                        api/passport/v1/extension#destroy
#                                      lti_launch POST     /lti/launch(.:format)                                                                                       lti#launch
#                                  lti_assessment POST     /lti/assessment(.:format)                                                                                   lti#assessment
#                                            home GET      /home(.:format)                                                                                             home#index
#                                            main GET      /main(.:format)                                                                                             home#index
#                                      home_about GET      /home/about(.:format)                                                                                       home#about
#                                    home_license GET      /home/license(.:format)                                                                                     home#license
#                                    home_privacy GET      /home/privacy(.:format)                                                                                     home#privacy
#                                    home_contact GET      /home/contact(.:format)                                                                                     home#contact
#                                new_course_modal GET      /home/new_course_modal(.:format)                                                                            home#new_course_modal
#                               python_ruby_modal GET      /home/python_ruby_modal(.:format)                                                                           home#python_ruby_modal
#                                                 GET      /admin/users/:id/edit(.:format)                                                                             admin/users#edit {:id=>/[^\/]+/}
#                                                 GET      /admin/users/:id(.:format)                                                                                  admin/users#show {:id=>/[^\/]+/}
#                                                 PATCH    /admin/users/:id(.:format)                                                                                  admin/users#update {:id=>/[^\/]+/}
#                                                 PUT      /admin/users/:id(.:format)                                                                                  admin/users#update {:id=>/[^\/]+/}
#                                                 DELETE   /admin/users/:id(.:format)                                                                                  admin/users#destroy {:id=>/[^\/]+/}
#                                      admin_root GET      /admin(.:format)                                                                                            admin/dashboard#index
#                      batch_action_admin_courses POST     /admin/courses/batch_action(.:format)                                                                       admin/courses#batch_action
#                                   admin_courses GET      /admin/courses(.:format)                                                                                    admin/courses#index
#                                                 POST     /admin/courses(.:format)                                                                                    admin/courses#create
#                                new_admin_course GET      /admin/courses/new(.:format)                                                                                admin/courses#new
#                               edit_admin_course GET      /admin/courses/:id/edit(.:format)                                                                           admin/courses#edit
#                                    admin_course GET      /admin/courses/:id(.:format)                                                                                admin/courses#show
#                                                 PATCH    /admin/courses/:id(.:format)                                                                                admin/courses#update
#                                                 PUT      /admin/courses/:id(.:format)                                                                                admin/courses#update
#                                                 DELETE   /admin/courses/:id(.:format)                                                                                admin/courses#destroy
#             batch_action_admin_course_offerings POST     /admin/course_offerings/batch_action(.:format)                                                              admin/course_offerings#batch_action
#                          admin_course_offerings GET      /admin/course_offerings(.:format)                                                                           admin/course_offerings#index
#                                                 POST     /admin/course_offerings(.:format)                                                                           admin/course_offerings#create
#                       new_admin_course_offering GET      /admin/course_offerings/new(.:format)                                                                       admin/course_offerings#new
#                      edit_admin_course_offering GET      /admin/course_offerings/:id/edit(.:format)                                                                  admin/course_offerings#edit
#                           admin_course_offering GET      /admin/course_offerings/:id(.:format)                                                                       admin/course_offerings#show
#                                                 PATCH    /admin/course_offerings/:id(.:format)                                                                       admin/course_offerings#update
#                                                 PUT      /admin/course_offerings/:id(.:format)                                                                       admin/course_offerings#update
#                                                 DELETE   /admin/course_offerings/:id(.:format)                                                                       admin/course_offerings#destroy
#                 batch_action_admin_course_roles POST     /admin/course_roles/batch_action(.:format)                                                                  admin/course_roles#batch_action
#                              admin_course_roles GET      /admin/course_roles(.:format)                                                                               admin/course_roles#index
#                                                 POST     /admin/course_roles(.:format)                                                                               admin/course_roles#create
#                           new_admin_course_role GET      /admin/course_roles/new(.:format)                                                                           admin/course_roles#new
#                          edit_admin_course_role GET      /admin/course_roles/:id/edit(.:format)                                                                      admin/course_roles#edit
#                               admin_course_role GET      /admin/course_roles/:id(.:format)                                                                           admin/course_roles#show
#                                                 PATCH    /admin/course_roles/:id(.:format)                                                                           admin/course_roles#update
#                                                 PUT      /admin/course_roles/:id(.:format)                                                                           admin/course_roles#update
#                                 admin_dashboard GET      /admin/dashboard(.:format)                                                                                  admin/dashboard#index
#                       batch_action_admin_errors POST     /admin/errors/batch_action(.:format)                                                                        admin/errors#batch_action
#                                    admin_errors GET      /admin/errors(.:format)                                                                                     admin/errors#index
#                                     admin_error GET      /admin/errors/:id(.:format)                                                                                 admin/errors#show
#                    batch_action_admin_exercises POST     /admin/exercises/batch_action(.:format)                                                                     admin/exercises#batch_action
#                                 admin_exercises GET      /admin/exercises(.:format)                                                                                  admin/exercises#index
#                                                 POST     /admin/exercises(.:format)                                                                                  admin/exercises#create
#                              new_admin_exercise GET      /admin/exercises/new(.:format)                                                                              admin/exercises#new
#                             edit_admin_exercise GET      /admin/exercises/:id/edit(.:format)                                                                         admin/exercises#edit
#                                  admin_exercise GET      /admin/exercises/:id(.:format)                                                                              admin/exercises#show
#                                                 PATCH    /admin/exercises/:id(.:format)                                                                              admin/exercises#update
#                                                 PUT      /admin/exercises/:id(.:format)                                                                              admin/exercises#update
#                                                 DELETE   /admin/exercises/:id(.:format)                                                                              admin/exercises#destroy
#         batch_action_admin_exercise_collections POST     /admin/exercise_collections/batch_action(.:format)                                                          admin/exercise_collections#batch_action
#                      admin_exercise_collections GET      /admin/exercise_collections(.:format)                                                                       admin/exercise_collections#index
#                                                 POST     /admin/exercise_collections(.:format)                                                                       admin/exercise_collections#create
#                   new_admin_exercise_collection GET      /admin/exercise_collections/new(.:format)                                                                   admin/exercise_collections#new
#                  edit_admin_exercise_collection GET      /admin/exercise_collections/:id/edit(.:format)                                                              admin/exercise_collections#edit
#                       admin_exercise_collection GET      /admin/exercise_collections/:id(.:format)                                                                   admin/exercise_collections#show
#                                                 PATCH    /admin/exercise_collections/:id(.:format)                                                                   admin/exercise_collections#update
#                                                 PUT      /admin/exercise_collections/:id(.:format)                                                                   admin/exercise_collections#update
#                                                 DELETE   /admin/exercise_collections/:id(.:format)                                                                   admin/exercise_collections#destroy
#                 batch_action_admin_global_roles POST     /admin/global_roles/batch_action(.:format)                                                                  admin/global_roles#batch_action
#                              admin_global_roles GET      /admin/global_roles(.:format)                                                                               admin/global_roles#index
#                               admin_global_role GET      /admin/global_roles/:id(.:format)                                                                           admin/global_roles#show
#             batch_action_admin_license_policies POST     /admin/license_policies/batch_action(.:format)                                                              admin/license_policies#batch_action
#                          admin_license_policies GET      /admin/license_policies(.:format)                                                                           admin/license_policies#index
#                                                 POST     /admin/license_policies(.:format)                                                                           admin/license_policies#create
#                        new_admin_license_policy GET      /admin/license_policies/new(.:format)                                                                       admin/license_policies#new
#                       edit_admin_license_policy GET      /admin/license_policies/:id/edit(.:format)                                                                  admin/license_policies#edit
#                            admin_license_policy GET      /admin/license_policies/:id(.:format)                                                                       admin/license_policies#show
#                                                 PATCH    /admin/license_policies/:id(.:format)                                                                       admin/license_policies#update
#                                                 PUT      /admin/license_policies/:id(.:format)                                                                       admin/license_policies#update
#                                                 DELETE   /admin/license_policies/:id(.:format)                                                                       admin/license_policies#destroy
#                batch_action_admin_lms_instances POST     /admin/lms_instances/batch_action(.:format)                                                                 admin/lms_instances#batch_action
#                             admin_lms_instances GET      /admin/lms_instances(.:format)                                                                              admin/lms_instances#index
#                                                 POST     /admin/lms_instances(.:format)                                                                              admin/lms_instances#create
#                          new_admin_lms_instance GET      /admin/lms_instances/new(.:format)                                                                          admin/lms_instances#new
#                         edit_admin_lms_instance GET      /admin/lms_instances/:id/edit(.:format)                                                                     admin/lms_instances#edit
#                              admin_lms_instance GET      /admin/lms_instances/:id(.:format)                                                                          admin/lms_instances#show
#                                                 PATCH    /admin/lms_instances/:id(.:format)                                                                          admin/lms_instances#update
#                                                 PUT      /admin/lms_instances/:id(.:format)                                                                          admin/lms_instances#update
#                                                 DELETE   /admin/lms_instances/:id(.:format)                                                                          admin/lms_instances#destroy
#                    batch_action_admin_lms_types POST     /admin/lms_types/batch_action(.:format)                                                                     admin/lms_types#batch_action
#                                 admin_lms_types GET      /admin/lms_types(.:format)                                                                                  admin/lms_types#index
#                                                 POST     /admin/lms_types(.:format)                                                                                  admin/lms_types#create
#                              new_admin_lms_type GET      /admin/lms_types/new(.:format)                                                                              admin/lms_types#new
#                             edit_admin_lms_type GET      /admin/lms_types/:id/edit(.:format)                                                                         admin/lms_types#edit
#                                  admin_lms_type GET      /admin/lms_types/:id(.:format)                                                                              admin/lms_types#show
#                                                 PATCH    /admin/lms_types/:id(.:format)                                                                              admin/lms_types#update
#                                                 PUT      /admin/lms_types/:id(.:format)                                                                              admin/lms_types#update
#                batch_action_admin_organizations POST     /admin/organizations/batch_action(.:format)                                                                 admin/organizations#batch_action
#                             admin_organizations GET      /admin/organizations(.:format)                                                                              admin/organizations#index
#                                                 POST     /admin/organizations(.:format)                                                                              admin/organizations#create
#                          new_admin_organization GET      /admin/organizations/new(.:format)                                                                          admin/organizations#new
#                         edit_admin_organization GET      /admin/organizations/:id/edit(.:format)                                                                     admin/organizations#edit
#                              admin_organization GET      /admin/organizations/:id(.:format)                                                                          admin/organizations#show
#                                                 PATCH    /admin/organizations/:id(.:format)                                                                          admin/organizations#update
#                                                 PUT      /admin/organizations/:id(.:format)                                                                          admin/organizations#update
#                        batch_action_admin_terms POST     /admin/terms/batch_action(.:format)                                                                         admin/terms#batch_action
#                                     admin_terms GET      /admin/terms(.:format)                                                                                      admin/terms#index
#                                                 POST     /admin/terms(.:format)                                                                                      admin/terms#create
#                                  new_admin_term GET      /admin/terms/new(.:format)                                                                                  admin/terms#new
#                                 edit_admin_term GET      /admin/terms/:id/edit(.:format)                                                                             admin/terms#edit
#                                      admin_term GET      /admin/terms/:id(.:format)                                                                                  admin/terms#show
#                                                 PATCH    /admin/terms/:id(.:format)                                                                                  admin/terms#update
#                                                 PUT      /admin/terms/:id(.:format)                                                                                  admin/terms#update
#                        batch_action_admin_users POST     /admin/users/batch_action(.:format)                                                                         admin/users#batch_action
#                                     admin_users GET      /admin/users(.:format)                                                                                      admin/users#index
#                                                 POST     /admin/users(.:format)                                                                                      admin/users#create
#                                  new_admin_user GET      /admin/users/new(.:format)                                                                                  admin/users#new
#                                 edit_admin_user GET      /admin/users/:id/edit(.:format)                                                                             admin/users#edit
#                                      admin_user GET      /admin/users/:id(.:format)                                                                                  admin/users#show
#                                                 PATCH    /admin/users/:id(.:format)                                                                                  admin/users#update
#                                                 PUT      /admin/users/:id(.:format)                                                                                  admin/users#update
#                                                 DELETE   /admin/users/:id(.:format)                                                                                  admin/users#destroy
#                  batch_action_admin_user_groups POST     /admin/user_groups/batch_action(.:format)                                                                   admin/user_groups#batch_action
#                               admin_user_groups GET      /admin/user_groups(.:format)                                                                                admin/user_groups#index
#                                                 POST     /admin/user_groups(.:format)                                                                                admin/user_groups#create
#                            new_admin_user_group GET      /admin/user_groups/new(.:format)                                                                            admin/user_groups#new
#                           edit_admin_user_group GET      /admin/user_groups/:id/edit(.:format)                                                                       admin/user_groups#edit
#                                admin_user_group GET      /admin/user_groups/:id(.:format)                                                                            admin/user_groups#show
#                                                 PATCH    /admin/user_groups/:id(.:format)                                                                            admin/user_groups#update
#                                                 PUT      /admin/user_groups/:id(.:format)                                                                            admin/user_groups#update
#                                                 DELETE   /admin/user_groups/:id(.:format)                                                                            admin/user_groups#destroy
#            batch_action_admin_workout_offerings POST     /admin/workout_offerings/batch_action(.:format)                                                             admin/workout_offerings#batch_action
#                         admin_workout_offerings GET      /admin/workout_offerings(.:format)                                                                          admin/workout_offerings#index
#                                                 POST     /admin/workout_offerings(.:format)                                                                          admin/workout_offerings#create
#                      new_admin_workout_offering GET      /admin/workout_offerings/new(.:format)                                                                      admin/workout_offerings#new
#                     edit_admin_workout_offering GET      /admin/workout_offerings/:id/edit(.:format)                                                                 admin/workout_offerings#edit
#                          admin_workout_offering GET      /admin/workout_offerings/:id(.:format)                                                                      admin/workout_offerings#show
#                                                 PATCH    /admin/workout_offerings/:id(.:format)                                                                      admin/workout_offerings#update
#                                                 PUT      /admin/workout_offerings/:id(.:format)                                                                      admin/workout_offerings#update
#                                                 DELETE   /admin/workout_offerings/:id(.:format)                                                                      admin/workout_offerings#destroy
#                                  admin_comments GET      /admin/comments(.:format)                                                                                   admin/comments#index
#                                                 POST     /admin/comments(.:format)                                                                                   admin/comments#create
#                                   admin_comment GET      /admin/comments/:id(.:format)                                                                               admin/comments#show
#                                                 DELETE   /admin/comments/:id(.:format)                                                                               admin/comments#destroy
#                               sse_feedback_wait GET      /sse/feedback_wait(.:format)                                                                                sse#feedback_wait
#                             sse_feedback_update GET      /sse/feedback_update(.:format)                                                                              sse#feedback_update
#                               sse_feedback_poll GET      /sse/feedback_poll(.:format)                                                                                sse#feedback_poll
#                                                 POST     /course_offerings/:id/upload_roster(.:format)                                                               course_offerings#upload_roster
#                               request_extension GET      /request_extension(.:format)                                                                                workout_offerings#request_extension
#                                   add_extension POST     /add_extension(.:format)                                                                                    workout_offerings#add_extension
#                                             gym GET      /gym(.:format)                                                                                              workouts#gym
#                         exercises_call_open_pop GET      /gym/exercises/call_open_pop(.:format)                                                                      exercises#call_open_pop
#                                exercises_import GET      /gym/exercises_import(.:format)                                                                             exercises#upload_yaml
#                           exercises_yaml_create POST     /gym/exercises_yaml_create(.:format)                                                                        exercises#yaml_create
#                                exercises_upload GET      /gym/exercises/upload(.:format)                                                                             exercises#upload
#                              exercises_download GET      /gym/exercises/download(.:format)                                                                           exercises#download
#                         exercises_upload_create POST     /gym/exercises/upload_create(.:format)                                                                      exercises#upload_create
#                           exercises_upload_mcqs GET      /gym/exercises/upload_mcqs(.:format)                                                                        exercises#upload_mcqs
#                           exercises_create_mcqs POST     /gym/exercises/create_mcqs(.:format)                                                                        exercises#create_mcqs
#                                 random_exercise GET      /gym/exercises/any(.:format)                                                                                exercises#random_exercise
#                               exercise_practice GET      /gym/exercises/:id/practice(.:format)                                                                       exercises#practice
#                               exercise_evaluate PATCH    /gym/exercises/:id/practice(.:format)                                                                       exercises#evaluate
#                                  exercise_embed GET      /gym/exercises/:id/embed(.:format)                                                                          exercises#embed
#                                exercises_search GET      /gym/exercises/search(.:format)                                                                             exercises#search
#                            exercises_query_data GET      /gym/exercises/query_data(.:format)                                                                         exercises#query_data
#                  download_exercise_attempt_data GET      /gym/exercises/download_attempt_data(.:format)                                                              exercises#download_attempt_data
#                                exercises_export GET      /gym/exercises/export(.:format)                                                                             exercises#export
#                                       exercises GET      /gym/exercises(.:format)                                                                                    exercises#index
#                                                 POST     /gym/exercises(.:format)                                                                                    exercises#create
#                                    new_exercise GET      /gym/exercises/new(.:format)                                                                                exercises#new
#                                   edit_exercise GET      /gym/exercises/:id/edit(.:format)                                                                           exercises#edit
#                                        exercise GET      /gym/exercises/:id(.:format)                                                                                exercises#show
#                                                 PATCH    /gym/exercises/:id(.:format)                                                                                exercises#update
#                                                 PUT      /gym/exercises/:id(.:format)                                                                                exercises#update
#                                                 DELETE   /gym/exercises/:id(.:format)                                                                                exercises#destroy
#                                   workout_embed GET      /gym/workouts/embed(/:workout_id)(.:format)                                                                 workouts#embed
#                               workouts_download GET      /gym/workouts/download(.:format)                                                                            workouts#download
#                                                 GET      /gym/workouts/:id/add_exercises(.:format)                                                                   workouts#add_exercises
#                         workouts_link_exercises POST     /gym/workouts/link_exercises(.:format)                                                                      workouts#link_exercises
#                            workouts_with_search GET      /gym/workouts/new_with_search/:searchkey(.:format)                                                          workouts#new_with_search
#                        workouts_exercise_search POST     /gym/workouts/new_with_search(.:format)                                                                     workouts#new_with_search
#                         new_or_existing_workout GET      /gym/workouts/new_or_existing(.:format)                                                                     workouts#new_or_existing
#                                     new_workout GET      /gym/workouts/new(.:format)                                                                                 workouts#new
#                                    edit_workout GET      /gym/workouts/:id/edit(.:format)                                                                            workouts#edit
#                                   clone_workout GET      /gym/workouts/:id/clone(.:format)                                                                           workouts#clone
#                                practice_workout GET      /gym/workouts/:id/practice(.:format)                                                                        workouts#practice
#                                workout_evaluate GET      /gym/workouts/:id/evaluate(.:format)                                                                        workouts#evaluate
#                                  workouts_dummy GET      /gym/workouts_dummy(.:format)                                                                               workouts#dummy
#                                 workouts_import GET      /gym/workouts_import(.:format)                                                                              workouts#upload_yaml
#                            workouts_yaml_create POST     /gym/workouts_yaml_create(.:format)                                                                         workouts#yaml_create
#                                 workouts_search POST     /gym/workouts/search(.:format)                                                                              workouts#search
#                   download_workout_attempt_data GET      /gym/workouts/:id/download_attempt_data(.:format)                                                           workouts#download_attempt_data
#                                 workouts_export GET      /gym/workouts/export(.:format)                                                                              workouts#export
#                         workouts_student_search GET      /gym/workouts/search_students(.:format)                                                                     workouts#search_students
#                                        workouts GET      /gym/workouts(.:format)                                                                                     workouts#index
#                                                 POST     /gym/workouts(.:format)                                                                                     workouts#create
#                                         workout GET      /gym/workouts/:id(.:format)                                                                                 workouts#show
#                                                 PATCH    /gym/workouts/:id(.:format)                                                                                 workouts#update
#                                                 PUT      /gym/workouts/:id(.:format)                                                                                 workouts#update
#                                                 DELETE   /gym/workouts/:id(.:format)                                                                                 workouts#destroy
#                     organization_courses_search GET      /courses/:organization_id/search(.:format)                                                                  courses#search
#                        organization_course_find POST     /courses/:organization_id/find(.:format)                                                                    courses#find
#                                organization_new GET      /courses/:organization_id/new(.:format)                                                                     courses#new
#          organization_request_privileged_access GET      /courses/:organization_id/:id/request_privileged_access/:requester_id(.:format)                             courses#request_privileged_access
#                     organization_courses_create POST     /courses/:organization_id/create(.:format)                                                                  courses#create
#                        organization_course_edit GET      /courses/:organization_id/:id/edit(.:format)                                                                courses#edit
#            organization_course_privileged_users GET      /courses/:organization_id/:id/privileged_users(.:format)                                                    courses#privileged_users
#                organization_new_course_offering GET      /courses/:organization_id/:course_id/new_offering(.:format)                                                 course_offerings#new
#             organization_course_offering_create POST     /courses/:organization_id/:course_id/create_offering(.:format)                                              course_offerings#create
#                                                 GET      /courses/:organization_id/:course_id/:term_id/tab_content/:tab(.:format)                                    courses#tab_content
#              organization_new_course_enrollment GET      /courses/:organization_id/:course_id/:term_id/course_enrollments/new(.:format)                              course_enrollments#new
#                organization_course_enroll_users POST     /courses/:organization_id/:course_id/:term_id/course_enrollments/:course_offering_id/enroll_users(.:format) course_enrollments#enroll_users
#               organization_course_choose_roster GET      /courses/:organization_id/:course_id/:term_id/course_enrollments/choose_roster(.:format)                    course_enrollments#choose_roster
#               organization_course_roster_upload POST     /courses/:organization_id/:course_id/:term_id/course_enrollments/roster_upload(.:format)                    course_enrollments#roster_upload
#                        organization_new_workout GET      /courses/:organization_id/:course_id/:term_id/workouts/new(.:format)                                        workouts#new
#                      organization_clone_workout GET      /courses/:organization_id/:course_id/:term_id/workouts/:workout_id/clone(.:format)                          workouts#clone
#            organization_new_or_existing_workout GET      /courses/:organization_id/:course_id/:term_id/workouts/new_or_existing(.:format)                            workouts#new_or_existing
#                       organization_edit_workout GET      /courses/:organization_id/:course_id/:term_id/:workout_offering_id/edit_workout(.:format)                   workouts#edit
#          organization_workout_offering_practice GET      /courses/:organization_id/:course_id/:term_id/:id/practice(/:exercise_id)(.:format)                         workout_offerings#practice
#              organization_find_workout_offering GET      /courses/:organization_id/:course_id/:term_id/find_offering/:workout_name(.:format)                         workouts#find_offering
#          organization_workout_offering_exercise GET      /courses/:organization_id/:course_id/:term_id/:workout_offering_id/:id(.:format)                            exercises#practice
# organization_workout_offering_exercise_evaluate PATCH    /courses/:organization_id/:course_id/:term_id/:workout_offering_id/:id(.:format)                            exercises#evaluate
#   organization_workout_offering_exercise_review GET      /courses/:organization_id/:course_id/:term_id/:workout_offering_id/review/:review_user_id/:id(.:format)     exercises#practice
#                   organization_workout_offering GET      /courses/:organization_id/:course_id/:term_id/:id(.:format)                                                 workout_offerings#show
#            organization_workout_offering_review GET      /courses/:organization_id/:course_id/:term_id/review/:review_user_id/:id(.:format)                          workout_offerings#review
#      organization_workout_offering_activity_log GET      /courses/:organization_id/:course_id/:term_id/:id/activity_log(.:format)                                    workout_offerings#activity_log
#                   organization_course_gradebook POST     /courses/:organization_id/:id/:term_id/generate_gradebook(.:format)                                         courses#generate_gradebook
#                             organization_course GET      /courses/:organization_id/:id(/:term_id)(.:format)                                                          courses#show
#                                   organizations GET      /courses(.:format)                                                                                          organizations#index
#                                    organization GET      /courses/:id(.:format)                                                                                      organizations#show
#                   new_or_existing_organizations GET      /organizations/new_or_existing(.:format)                                                                    organizations#new_or_existing
#                            search_organizations GET      /organizations/search(.:format)                                                                             organizations#search
#                   abbr_suggestion_organizations GET      /organizations/abbr_suggestion(.:format)                                                                    organizations#abbr_suggestion
#                                                 POST     /organizations(.:format)                                                                                    organizations#create
#                          course_offering_enroll POST     /course_offerings/:course_offering_id/enroll(.:format)                                                      course_offerings#enroll
#                        course_offering_unenroll DELETE   /course_offerings/:course_offering_id/unenroll(.:format)                                                    course_offerings#unenroll
#                   course_offering_upload_roster GET|POST /course_offerings/:course_offering_id/upload_roster/:action(.:format)                                       upload_roster#:action
#                       course_offering_gradebook POST     /course_offerings/:course_offering_id/generate_gradebook(.:format)                                          course_offerings#generate_gradebook
#                     course_offering_add_workout POST     /course_offerings/:course_offering_id/add_workout/:workout_name(.:format)                                   course_offerings#add_workout
#                   course_offering_store_workout POST     /course_offerings/:course_offering_id/store_workout/:id(.:format)                                           course_offerings#store_workout
#           course_offering_search_enrolled_users GET      /course_offerings/:course_offering_id/search_enrolled_users(.:format)                                       course_offerings#search_enrolled_users
#                  remote_create_course_offerings POST     /course_offerings/remote_create(.:format)                                                                   course_offerings#remote_create
#                                course_offerings GET      /course_offerings(.:format)                                                                                 course_offerings#index
#                            edit_course_offering GET      /course_offerings/:id/edit(.:format)                                                                        course_offerings#edit
#                                 course_offering GET      /course_offerings/:id(.:format)                                                                             course_offerings#show
#                                                 PATCH    /course_offerings/:id(.:format)                                                                             course_offerings#update
#                                                 PUT      /course_offerings/:id(.:format)                                                                             course_offerings#update
#                               course_enrollment DELETE   /course_enrollments/:id(.:format)                                                                           course_enrollments#destroy
#                              user_group_members GET      /user_groups/:user_group_id/members(.:format)                                                               user_groups#members
#                user_group_review_access_request GET      /user_groups/:user_group_id/review_access_request/:requester_id/:user_id(.:format)                          user_groups#review_access_request
#                user_group_decide_access_request POST     /user_groups/:user_group_id/review_access_request/:requester_id/:user_id(.:format)                          user_groups#review_access_request
#                             user_group_add_user POST     /user_groups/:user_group_id/add_user/:user_id(.:format)                                                     user_groups#add_user
#                                  new_user_group GET      /user_groups/new(.:format)                                                                                  user_groups#new
#                             user_resource_files GET      /users/:user_id/media(.:format)                                                                             resource_files#index {:user_id=>/[^\/]+/}
#                                                 POST     /users/:user_id/media(.:format)                                                                             resource_files#create {:user_id=>/[^\/]+/}
#                          new_user_resource_file GET      /users/:user_id/media/new(.:format)                                                                         resource_files#new {:user_id=>/[^\/]+/}
#                         edit_user_resource_file GET      /users/:user_id/media/:id/edit(.:format)                                                                    resource_files#edit {:id=>/[^\/]+/, :user_id=>/[^\/]+/}
#                              user_resource_file GET      /users/:user_id/media/:id(.:format)                                                                         resource_files#show {:id=>/[^\/]+/, :user_id=>/[^\/]+/}
#                                                 PATCH    /users/:user_id/media/:id(.:format)                                                                         resource_files#update {:id=>/[^\/]+/, :user_id=>/[^\/]+/}
#                                                 PUT      /users/:user_id/media/:id(.:format)                                                                         resource_files#update {:id=>/[^\/]+/, :user_id=>/[^\/]+/}
#                                                 DELETE   /users/:user_id/media/:id(.:format)                                                                         resource_files#destroy {:id=>/[^\/]+/, :user_id=>/[^\/]+/}
#                           user_calc_performance GET      /users/:user_id/performance(.:format)                                                                       users#calc_performance {:user_id=>/[^\/]+/}
#                                           users GET      /users(.:format)                                                                                            users#index
#                                                 POST     /users(.:format)                                                                                            users#create
#                                        new_user GET      /users/new(.:format)                                                                                        users#new
#                                       edit_user GET      /users/:id/edit(.:format)                                                                                   users#edit {:id=>/[^\/]+/}
#                                            user GET      /users/:id(.:format)                                                                                        users#show {:id=>/[^\/]+/}
#                                                 PATCH    /users/:id(.:format)                                                                                        users#update {:id=>/[^\/]+/}
#                                                 PUT      /users/:id(.:format)                                                                                        users#update {:id=>/[^\/]+/}
#                                                 DELETE   /users/:id(.:format)                                                                                        users#destroy {:id=>/[^\/]+/}
#                user_facebook_omniauth_authorize GET|POST /users/auth/facebook(.:format)                                                                              users/omniauth_callbacks#passthru
#                 user_facebook_omniauth_callback GET|POST /users/auth/facebook/callback(.:format)                                                                     users/omniauth_callbacks#facebook
#           user_google_oauth2_omniauth_authorize GET|POST /users/auth/google_oauth2(.:format)                                                                         users/omniauth_callbacks#passthru
#            user_google_oauth2_omniauth_callback GET|POST /users/auth/google_oauth2/callback(.:format)                                                                users/omniauth_callbacks#google_oauth2
#                     user_cas_omniauth_authorize GET|POST /users/auth/cas(.:format)                                                                                   users/omniauth_callbacks#passthru
#                      user_cas_omniauth_callback GET|POST /users/auth/cas/callback(.:format)                                                                          users/omniauth_callbacks#cas
#                               new_user_password GET      /users/password/new(.:format)                                                                               devise/passwords#new
#                              edit_user_password GET      /users/password/edit(.:format)                                                                              devise/passwords#edit
#                                   user_password PATCH    /users/password(.:format)                                                                                   devise/passwords#update
#                                                 PUT      /users/password(.:format)                                                                                   devise/passwords#update
#                                                 POST     /users/password(.:format)                                                                                   devise/passwords#create
#                                    new_password GET      /new_password(.:format)                                                                                     devise/passwords#new
#                                   edit_password GET      /edit_password(.:format)                                                                                    devise/passwords#edit
#                                 update_password PUT      /update_password(.:format)                                                                                  devise/passwords#update
#                                 create_password POST     /create_password(.:format)                                                                                  devise/passwords#create
#                           new_user_registration GET      /signup(.:format)                                                                                           devise/registrations#new
#                               user_registration POST     /signup(.:format)                                                                                           devise/registrations#create
#                                new_user_session GET      /login(.:format)                                                                                            users/sessions#new
#                                    user_session POST     /login(.:format)                                                                                            devise/sessions#create
#                            destroy_user_session DELETE   /logout(.:format)                                                                                           devise/sessions#destroy
#                                            help GET      /help(.:format)                                                                                             help#index
#                                                 GET      /help/:action(.:format)                                                                                     help#:action
#                                                 GET      /static_pages/:action(.:format)                                                                             static_pages#:action
#                            static_pages_mockup1 GET      /static_pages/mockup1(.:format)                                                                             static_pages#mockup1
#                            static_pages_mockup2 GET      /static_pages/mockup2(.:format)                                                                             static_pages#mockup2
#                            static_pages_mockup3 GET      /static_pages/mockup3(.:format)                                                                             static_pages#mockup3
#                         static_pages_thumbnails GET      /static_pages/thumbnails(.:format)                                                                          static_pages#thumbnails
#                                     bad_request GET      /400(.:format)                                                                                              exception_handler/exceptions#show {:code=>:bad_request}
#                                    unauthorized GET      /401(.:format)                                                                                              exception_handler/exceptions#show {:code=>:unauthorized}
#                                payment_required GET      /402(.:format)                                                                                              exception_handler/exceptions#show {:code=>:payment_required}
#                                       forbidden GET      /403(.:format)                                                                                              exception_handler/exceptions#show {:code=>:forbidden}
#                                       not_found GET      /404(.:format)                                                                                              exception_handler/exceptions#show {:code=>:not_found}
#                              method_not_allowed GET      /405(.:format)                                                                                              exception_handler/exceptions#show {:code=>:method_not_allowed}
#                                  not_acceptable GET      /406(.:format)                                                                                              exception_handler/exceptions#show {:code=>:not_acceptable}
#                   proxy_authentication_required GET      /407(.:format)                                                                                              exception_handler/exceptions#show {:code=>:proxy_authentication_required}
#                                 request_timeout GET      /408(.:format)                                                                                              exception_handler/exceptions#show {:code=>:request_timeout}
#                                        conflict GET      /409(.:format)                                                                                              exception_handler/exceptions#show {:code=>:conflict}
#                                            gone GET      /410(.:format)                                                                                              exception_handler/exceptions#show {:code=>:gone}
#                                 length_required GET      /411(.:format)                                                                                              exception_handler/exceptions#show {:code=>:length_required}
#                             precondition_failed GET      /412(.:format)                                                                                              exception_handler/exceptions#show {:code=>:precondition_failed}
#                               payload_too_large GET      /413(.:format)                                                                                              exception_handler/exceptions#show {:code=>:payload_too_large}
#                                    uri_too_long GET      /414(.:format)                                                                                              exception_handler/exceptions#show {:code=>:uri_too_long}
#                          unsupported_media_type GET      /415(.:format)                                                                                              exception_handler/exceptions#show {:code=>:unsupported_media_type}
#                           range_not_satisfiable GET      /416(.:format)                                                                                              exception_handler/exceptions#show {:code=>:range_not_satisfiable}
#                              expectation_failed GET      /417(.:format)                                                                                              exception_handler/exceptions#show {:code=>:expectation_failed}
#                             misdirected_request GET      /421(.:format)                                                                                              exception_handler/exceptions#show {:code=>:misdirected_request}
#                            unprocessable_entity GET      /422(.:format)                                                                                              exception_handler/exceptions#show {:code=>:unprocessable_entity}
#                                          locked GET      /423(.:format)                                                                                              exception_handler/exceptions#show {:code=>:locked}
#                               failed_dependency GET      /424(.:format)                                                                                              exception_handler/exceptions#show {:code=>:failed_dependency}
#                                       too_early GET      /425(.:format)                                                                                              exception_handler/exceptions#show {:code=>:too_early}
#                                upgrade_required GET      /426(.:format)                                                                                              exception_handler/exceptions#show {:code=>:upgrade_required}
#                           precondition_required GET      /428(.:format)                                                                                              exception_handler/exceptions#show {:code=>:precondition_required}
#                               too_many_requests GET      /429(.:format)                                                                                              exception_handler/exceptions#show {:code=>:too_many_requests}
#                 request_header_fields_too_large GET      /431(.:format)                                                                                              exception_handler/exceptions#show {:code=>:request_header_fields_too_large}
#                   unavailable_for_legal_reasons GET      /451(.:format)                                                                                              exception_handler/exceptions#show {:code=>:unavailable_for_legal_reasons}
#                           internal_server_error GET      /500(.:format)                                                                                              exception_handler/exceptions#show {:code=>:internal_server_error}
#                                 not_implemented GET      /501(.:format)                                                                                              exception_handler/exceptions#show {:code=>:not_implemented}
#                                     bad_gateway GET      /502(.:format)                                                                                              exception_handler/exceptions#show {:code=>:bad_gateway}
#                             service_unavailable GET      /503(.:format)                                                                                              exception_handler/exceptions#show {:code=>:service_unavailable}
#                                 gateway_timeout GET      /504(.:format)                                                                                              exception_handler/exceptions#show {:code=>:gateway_timeout}
#                      http_version_not_supported GET      /505(.:format)                                                                                              exception_handler/exceptions#show {:code=>:http_version_not_supported}
#                         variant_also_negotiates GET      /506(.:format)                                                                                              exception_handler/exceptions#show {:code=>:variant_also_negotiates}
#                            insufficient_storage GET      /507(.:format)                                                                                              exception_handler/exceptions#show {:code=>:insufficient_storage}
#                                   loop_detected GET      /508(.:format)                                                                                              exception_handler/exceptions#show {:code=>:loop_detected}
#                        bandwidth_limit_exceeded GET      /509(.:format)                                                                                              exception_handler/exceptions#show {:code=>:bandwidth_limit_exceeded}
#                                    not_extended GET      /510(.:format)                                                                                              exception_handler/exceptions#show {:code=>:not_extended}
#                 network_authentication_required GET      /511(.:format)                                                                                              exception_handler/exceptions#show {:code=>:network_authentication_required}
#                              rails_service_blob GET      /rails/active_storage/blobs/:signed_id/*filename(.:format)                                                  active_storage/blobs#show
#                       rails_blob_representation GET      /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)                    active_storage/representations#show
#                              rails_disk_service GET      /rails/active_storage/disk/:encoded_key/*filename(.:format)                                                 active_storage/disk#show
#                       update_rails_disk_service PUT      /rails/active_storage/disk/:encoded_token(.:format)                                                         active_storage/disk#update
#                            rails_direct_uploads POST     /rails/active_storage/direct_uploads(.:format)                                                              active_storage/direct_uploads#create

Rails.application.routes.draw do

  root 'home#index'

  namespace :api do
    namespace :passport do
      namespace :v1 do
        post 'register' => 'registration#register'
        post 'extension' => 'extension#create'
        delete 'extension' => 'extension#destroy'
      end
    end
  end

  post 'lti/launch', as: :lti_launch # => 'workout_offerings#practice', as: :lti_workout_offering_practice

  post 'lti/assessment'

  get 'home' => 'home#index'
  get 'main' => 'home#index'
  get 'home/about'
  get 'home/license'
  get 'home/privacy'
  get 'home/contact'
  get 'home/new_course_modal', as: :new_course_modal
  get 'home/python_ruby_modal', as: :python_ruby_modal

  # routes anchored at /admin
  # First, we have to override some of the ActiveAdmin auto-generated
  # routes, since our user ids and file ids use restricted characters
  get '/admin/users/:id/edit(.:format)' => 'admin/users#edit',
    constraints: { id: /[^\/]+/ }
  get '/admin/users/:id' => 'admin/users#show',
    constraints: { id: /[^\/]+/ }
  patch '/admin/users/:id' => 'admin/users#update',
    constraints: { id: /[^\/]+/ }
  put '/admin/users/:id' => 'admin/users#update',
    constraints: { id: /[^\/]+/ }
  delete '/admin/users/:id' => 'admin/users#destroy',
    constraints: { id: /[^\/]+/ }
  ActiveAdmin.routes(self)


  get 'sse/feedback_wait'
  get 'sse/feedback_update'
  get 'sse/feedback_poll'
  post '/course_offerings/:id/upload_roster' => 'course_offerings#upload_roster'

  get '/request_extension' => 'workout_offerings#request_extension'
  post '/add_extension' => 'workout_offerings#add_extension'

  # All of the routes anchored at /gym
  scope :gym do
    # The top-level gym route
    get '/' => 'workouts#gym', as: :gym

    # /gym/exercises ...
    get 'exercises/call_open_pop' => 'exercises#call_open_pop'
    get  'exercises_import' => 'exercises#upload_yaml'  # REMOVE
    post  'exercises_yaml_create' => 'exercises#yaml_create' # REMOVE
    get  'exercises/upload' => 'exercises#upload', as: :exercises_upload
    get  'exercises/download' => 'exercises#download', as: :exercises_download
    post 'exercises/upload_create' => 'exercises#upload_create'
    get  'exercises/upload_mcqs' => 'exercises#upload_mcqs',
      as: :exercises_upload_mcqs  # REMOVE
    post 'exercises/create_mcqs' => 'exercises#create_mcqs' # REMOVE
    get  '/exercises/any' => 'exercises#random_exercise',
      as: :random_exercise
    get 'exercises/:id/practice' => 'exercises#practice',
      as: :exercise_practice
    patch 'exercises/:id/practice' => 'exercises#evaluate',
      as: :exercise_evaluate
    patch 'exercises/:id/practice/save_parsons_state' =>
      'exercises#save_parsons_state', as: :exercise_save_parsons_state
		get 'exercises/:id/embed' => 'exercises#embed', as: :exercise_embed
    get 'exercises/search' => 'exercises#search', as: :exercises_search
    get 'exercises/query_data' => 'exercises#query_data',
      as: :exercises_query_data
    get 'exercises/download_attempt_data' =>
      'exercises#download_attempt_data', as: :download_exercise_attempt_data
    get 'exercises/export' => 'exercises#export', as: :exercises_export
    # At the bottom, so the routes above take precedence over existing ids
    resources :exercises

    # /gym/workouts ...
    get  'workouts/embed(/:workout_id)' => 'workouts#embed', as: :workout_embed
    get  'workouts/download' => 'workouts#download'
    get  'workouts/:id/add_exercises' => 'workouts#add_exercises'
    post 'workouts/link_exercises'  => 'workouts#link_exercises'
    get  'workouts/new_with_search/:searchkey'  => 'workouts#new_with_search',
      as: :workouts_with_search
    post 'workouts/new_with_search'  => 'workouts#new_with_search',
      as: :workouts_exercise_search
    get 'workouts/new_or_existing' => 'workouts#new_or_existing', as: :new_or_existing_workout
    get 'workouts/new' => 'workouts#new', as: :new_workout
    get 'workouts/:id/edit' => 'workouts#edit', as: :edit_workout
    get 'workouts/:id/clone' => 'workouts#clone', as: :clone_workout
    get  'workouts/:id/practice' => 'workouts#practice',
      as: :practice_workout
    get  'workouts/:id/evaluate' => 'workouts#evaluate', as: :workout_evaluate
    get  'workouts_dummy' => 'workouts#dummy'
    get  'workouts_import' => 'workouts#upload_yaml' # REMOVE?
    post  'workouts_yaml_create' => 'workouts#yaml_create' # REMOVE?
    post 'workouts/search' => 'workouts#search', as: :workouts_search
    get 'workouts/:id/download_attempt_data' =>
      'workouts#download_attempt_data', as: :download_workout_attempt_data
    get 'workouts/export' => 'workouts#export', as: :workouts_export
    get 'workouts/search_students' => 'workouts#search_students', as: :workouts_student_search
    # At the bottom, so the routes above take precedence over existing ids
    resources :workouts, except: [ :new, :edit ]
  end

  # All of the routes anchored at /courses
  resources :organizations, only: [ :index, :show ], path: '/courses' do
    get 'search' => 'courses#search', as: :courses_search
    post 'find' => 'courses#find', as: :course_find
    get 'new' => 'courses#new'
    get ':id/request_privileged_access/:requester_id' => 'courses#request_privileged_access',
      as: :request_privileged_access
    post 'create' => 'courses#create', as: :courses_create
    get ':id/edit' => 'courses#edit', as: :course_edit
    get ':id/privileged_users' => 'courses#privileged_users', as: :course_privileged_users
    get ':course_id/new_offering' => 'course_offerings#new', as: :new_course_offering
    post ':course_id/create_offering' => 'course_offerings#create', as: :course_offering_create
    get ':course_id/:term_id/select_offering' => 'course_offerings#select_offering', as: :course_select_offering
    get ':course_id/:term_id/tab_content/:tab' => 'courses#tab_content'
    get ':course_id/:term_id/course_enrollments/new' => 'course_enrollments#new', as: :new_course_enrollment
    post ':course_id/:term_id/course_enrollments/:course_offering_id/enroll_users' => 'course_enrollments#enroll_users', as: :course_enroll_users
    get ':course_id/:term_id/course_enrollments/choose_roster' => 'course_enrollments#choose_roster', as: :course_choose_roster
    post ':course_id/:term_id/course_enrollments/roster_upload' => 'course_enrollments#roster_upload', as: :course_roster_upload
    get ':course_id/:term_id/workouts/new' => 'workouts#new', as: :new_workout
    get ':course_id/:term_id/workouts/:workout_id/clone' => 'workouts#clone', as: :clone_workout
    get ':course_id/:term_id/workouts/new_or_existing' => 'workouts#new_or_existing', as: :new_or_existing_workout
    get ':course_id/:term_id/workouts/:id/practice(/:exercise_id)' => 'workouts#course_workout_practice', as: :course_workout_practice
    get ':course_id/:term_id/workouts/:id' => 'workouts#course_workout_show', as: :course_workout
    get ':course_id/:term_id/:workout_offering_id/edit_workout' => 'workouts#edit', as: :edit_workout
    get ':course_id/:term_id/:id/practice(/:exercise_id)' => 'workout_offerings#practice', as: :workout_offering_practice
    get ':course_id/:term_id/find_offering/:workout_name' => 'workouts#find_offering', as: :find_workout_offering
    get ':course_id/:term_id/:workout_offering_id/:id' => 'exercises#practice', as: :workout_offering_exercise
    patch ':course_id/:term_id/:workout_offering_id/:id' => 'exercises#evaluate', as: :workout_offering_exercise_evaluate
    get ':course_id/:term_id/:workout_offering_id/review/:review_user_id/:id' => 'exercises#practice', as: :workout_offering_exercise_review
    get ':course_id/:term_id/:id' => 'workout_offerings#show', as: :workout_offering
    get ':course_id/:term_id/:id/error' => 'workout_offerings#error', as: :workout_offering_error
    get ':course_id/:term_id/review/:review_user_id/:id' => 'workout_offerings#review', as: :workout_offering_review
    get ':course_id/:term_id/:id/activity_log' => 'workout_offerings#activity_log', as: :workout_offering_activity_log
    post ':id/:term_id/generate_gradebook/' => 'courses#generate_gradebook', as: :course_gradebook
    get ':id(/:term_id)' => 'courses#show', as: :course
  end

  # Organization routes, separate from courses
  resources :organizations, only: :create do
    collection do
      get 'new_or_existing'
      get 'search'
      get 'abbr_suggestion'
    end
  end

  resources :course_offerings, only: [ :edit, :update, :index, :show ] do
    post 'enroll' => :enroll, as: :enroll
    delete 'unenroll' => :unenroll, as: :unenroll
    get 'upload_roster' => 'upload_roster#index', as: :upload_roster
    post 'upload_roster/upload' => 'upload_roster#upload', as: :upload_roster_upload
    post 'generate_gradebook' => :generate_gradebook, as: :gradebook
    post 'add_workout/:workout_name' => 'course_offerings#add_workout', as: :add_workout
    post 'store_workout/:id' => :store_workout, as: :store_workout
    get '/search_enrolled_users' => :search_enrolled_users, as: :search_enrolled_users
    collection do
      post 'remote_create' => :remote_create, as: :remote_create
    end
  end

  resources :course_enrollments, only: [ :destroy ]

  resources :user_groups, only: [ :new ] do
    get 'members' => 'user_groups#members', as: :members
    get 'review_access_request/:requester_id/:user_id' => 'user_groups#review_access_request', as: :review_access_request
    post 'review_access_request/:requester_id/:user_id' => 'user_groups#review_access_request', as: :decide_access_request
    post 'add_user/:user_id' => 'user_groups#add_user', as: :add_user
  end

  # All of the routes anchored at /users
  resources :users, constraints: { id: /[^\/]+/ } do
    resources :resource_files, path: 'media',
      constraints: { id: /[^\/]+/ }
    # This route is broken, since there is no such method
    # post 'resource_files/uploadFile' => 'resource_files#uploadFile'
    get 'performance' => :calc_performance, as: :calc_performance
  end

  #OmniAuth for Facebook
  devise_for :users,
    controllers: { omniauth_callbacks: 'users/omniauth_callbacks', registrations: 'registrations' },
    skip: [:registrations, :sessions] # skipping these because routes are being defined below
  as :user do
    get '/new_password' => 'devise/passwords#new', as: :new_password
    get '/edit_password' => 'devise/passwords#edit', as: :edit_password
    put '/update_password' => 'devise/passwords#update', as: :update_password
    post '/create_password' => 'devise/passwords#create', as: :create_password
    get '/signup' => 'devise/registrations#new', as: :new_user_registration
    post '/signup' => 'devise/registrations#create', as: :user_registration
    # use the overridden login action
    get '/login' => 'users/sessions#new', as: :new_user_session
    post '/login' => 'devise/sessions#create', as: :user_session
    delete '/logout' => 'devise/sessions#destroy', as: :destroy_user_session
  end

  get 'help' => 'help#index'
  get 'help/exercise_format' => 'help#exercise_format'
  get 'help/exercise_peml_format' => 'help#exercise_peml_format'
  get 'help/lti_configuration' => 'help#lti_configuration'
  get 'help/specifying_due_dates' => 'help#specifying_due_dates'

  get 'static_pages/home' => 'static_pages#home'
  get 'static_pages/info' => 'static_pages#info'
  get 'static_pages/splash' => 'static_pages#splash'
  get 'static_pages/typography' => 'static_pages#typography'
  get 'static_pages/mockup1' => 'static_pages#mockup1'
  get 'static_pages/mockup2' => 'static_pages#mockup2'
  get 'static_pages/mockup3' => 'static_pages#mockup3'
  get 'static_pages/thumbnails' => 'static_pages#thumbnails'

  # match 'help/:action', to: 'help', via: [:get]
  # match 'static_pages/:action', to: 'static_pages', via: [:get]
end

=begin
 Prefix Verb   URI Pattern                            Controller#Action
              workouts GET    /workouts(.:format)                    workouts#index
                       POST   /workouts(.:format)                    workouts#create
           new_workout GET    /workouts/new(.:format)                workouts#new
          edit_workout GET    /workouts/:id/edit(.:format)           workouts#edit
               workout GET    /workouts/:id(.:format)                workouts#show
                       PATCH  /workouts/:id(.:format)                workouts#update
                       PUT    /workouts/:id(.:format)                workouts#update
                       DELETE /workouts/:id(.:format)                workouts#destroy
                  root GET    /                                      static_pages#home
     static_pages_home GET    /static_pages/home(.:format)           static_pages#home
     static_pages_help GET    /static_pages/help(.:format)           static_pages#help
  static_pages_mockup1 GET    /static_pages/mockup1(.:format)        static_pages#mockup1
  static_pages_mockup2 GET    /static_pages/mockup2(.:format)        static_pages#mockup2
  static_pages_mockup3 GET    /static_pages/mockup3(.:format)        static_pages#mockup3
             exercises GET    /exercises(.:format)                   exercises#index
                       POST   /exercises(.:format)                   exercises#create
          new_exercise GET    /exercises/new(.:format)               exercises#new
         edit_exercise GET    /exercises/:id/edit(.:format)          exercises#edit
              exercise GET    /exercises/:id(.:format)               exercises#show
                       PATCH  /exercises/:id(.:format)               exercises#update
                       PUT    /exercises/:id(.:format)               exercises#update
                       DELETE /exercises/:id(.:format)               exercises#destroy
               choices GET    /choices(.:format)                     choices#index
                       POST   /choices(.:format)                     choices#create
            new_choice GET    /choices/new(.:format)                 choices#new
           edit_choice GET    /choices/:id/edit(.:format)            choices#edit
                choice GET    /choices/:id(.:format)                 choices#show
                       PATCH  /choices/:id(.:format)                 choices#update
                       PUT    /choices/:id(.:format)                 choices#update
                       DELETE /choices/:id(.:format)                 choices#destroy
                 stems GET    /stems(.:format)                       stems#index
                       POST   /stems(.:format)                       stems#create
              new_stem GET    /stems/new(.:format)                   stems#new
             edit_stem GET    /stems/:id/edit(.:format)              stems#edit
                  stem GET    /stems/:id(.:format)                   stems#show
                       PATCH  /stems/:id(.:format)                   stems#update
                       PUT    /stems/:id(.:format)                   stems#update
                       DELETE /stems/:id(.:format)                   stems#destroy
      course_offerings GET    /course_offerings(.:format)            course_offerings#index
                       POST   /course_offerings(.:format)            course_offerings#create
   new_course_offering GET    /course_offerings/new(.:format)        course_offerings#new
  edit_course_offering GET    /course_offerings/:id/edit(.:format)   course_offerings#edit
       course_offering GET    /course_offerings/:id(.:format)        course_offerings#show
                       PATCH  /course_offerings/:id(.:format)        course_offerings#update
                       PUT    /course_offerings/:id(.:format)        course_offerings#update
                       DELETE /course_offerings/:id(.:format)        course_offerings#destroy
                 terms GET    /terms(.:format)                       terms#index
                       POST   /terms(.:format)                       terms#create
              new_term GET    /terms/new(.:format)                   terms#new
             edit_term GET    /terms/:id/edit(.:format)              terms#edit
                  term GET    /terms/:id(.:format)                   terms#show
                       PATCH  /terms/:id(.:format)                   terms#update
                       PUT    /terms/:id(.:format)                   terms#update
                       DELETE /terms/:id(.:format)                   terms#destroy
               courses GET    /courses(.:format)                     courses#index
                       POST   /courses(.:format)                     courses#create
            new_course GET    /courses/new(.:format)                 courses#new
           edit_course GET    /courses/:id/edit(.:format)            courses#edit
                course GET    /courses/:id(.:format)                 courses#show
                       PATCH  /courses/:id(.:format)                 courses#update
                       PUT    /courses/:id(.:format)                 courses#update
                       DELETE /courses/:id(.:format)                 courses#destroy
         organizations GET    /organizations(.:format)               organizations#index
                       POST   /organizations(.:format)               organizations#create
      new_organization GET    /organizations/new(.:format)           organizations#new
     edit_organization GET    /organizations/:id/edit(.:format)      organizations#edit
          organization GET    /organizations/:id(.:format)           organizations#show
                       PATCH  /organizations/:id(.:format)           organizations#update
                       PUT    /organizations/:id(.:format)           organizations#update
                       DELETE /organizations/:id(.:format)           organizations#destroy
             languages GET    /languages(.:format)                   languages#index
                       POST   /languages(.:format)                   languages#create
          new_language GET    /languages/new(.:format)               languages#new
         edit_language GET    /languages/:id/edit(.:format)          languages#edit
              language GET    /languages/:id(.:format)               languages#show
                       PATCH  /languages/:id(.:format)               languages#update
                       PUT    /languages/:id(.:format)               languages#update
                       DELETE /languages/:id(.:format)               languages#destroy
                  tags GET    /tags(.:format)                        tags#index
                       POST   /tags(.:format)                        tags#create
               new_tag GET    /tags/new(.:format)                    tags#new
              edit_tag GET    /tags/:id/edit(.:format)               tags#edit
                   tag GET    /tags/:id(.:format)                    tags#show
                       PATCH  /tags/:id(.:format)                    tags#update
                       PUT    /tags/:id(.:format)                    tags#update
                       DELETE /tags/:id(.:format)                    tags#destroy
    course_enrollments GET    /course_enrollments(.:format)          course_enrollments#index
                       POST   /course_enrollments(.:format)          course_enrollments#create
 new_course_enrollment GET    /course_enrollments/new(.:format)      course_enrollments#new
edit_course_enrollment GET    /course_enrollments/:id/edit(.:format) course_enrollments#edit
     course_enrollment GET    /course_enrollments/:id(.:format)      course_enrollments#show
                       PATCH  /course_enrollments/:id(.:format)      course_enrollments#update
                       PUT    /course_enrollments/:id(.:format)      course_enrollments#update
                       DELETE /course_enrollments/:id(.:format)      course_enrollments#destroy
          course_roles GET    /course_roles(.:format)                course_roles#index
                       POST   /course_roles(.:format)                course_roles#create
       new_course_role GET    /course_roles/new(.:format)            course_roles#new
      edit_course_role GET    /course_roles/:id/edit(.:format)       course_roles#edit
           course_role GET    /course_roles/:id(.:format)            course_roles#show
                       PATCH  /course_roles/:id(.:format)            course_roles#update
                       PUT    /course_roles/:id(.:format)            course_roles#update
                       DELETE /course_roles/:id(.:format)            course_roles#destroy
          global_roles GET    /global_roles(.:format)                global_roles#index
                       POST   /global_roles(.:format)                global_roles#create
       new_global_role GET    /global_roles/new(.:format)            global_roles#new
      edit_global_role GET    /global_roles/:id/edit(.:format)       global_roles#edit
           global_role GET    /global_roles/:id(.:format)            global_roles#show
                       PATCH  /global_roles/:id(.:format)            global_roles#update
                       PUT    /global_roles/:id(.:format)            global_roles#update
                       DELETE /global_roles/:id(.:format)            global_roles#destroy
                       GET    /course_enrollments(.:format)          course_enrollments#index
                       POST   /course_enrollments(.:format)          course_enrollments#create
                       GET    /course_enrollments/new(.:format)      course_enrollments#new
                       GET    /course_enrollments/:id/edit(.:format) course_enrollments#edit
                       GET    /course_enrollments/:id(.:format)      course_enrollments#show
                       PATCH  /course_enrollments/:id(.:format)      course_enrollments#update
                       PUT    /course_enrollments/:id(.:format)      course_enrollments#update
                       DELETE /course_enrollments/:id(.:format)      course_enrollments#destroy
                       GET    /course_roles(.:format)                course_roles#index
                       POST   /course_roles(.:format)                course_roles#create
                       GET    /course_roles/new(.:format)            course_roles#new
                       GET    /course_roles/:id/edit(.:format)       course_roles#edit
                       GET    /course_roles/:id(.:format)            course_roles#show
                       PATCH  /course_roles/:id(.:format)            course_roles#update
                       PUT    /course_roles/:id(.:format)            course_roles#update
                       DELETE /course_roles/:id(.:format)            course_roles#destroy
                 users GET    /users(.:format)                       users#index
                       POST   /users(.:format)                       users#create
              new_user GET    /users/new(.:format)                   users#new
             edit_user GET    /users/:id/edit(.:format)              users#edit
                  user GET    /users/:id(.:format)                   users#show
                       PATCH  /users/:id(.:format)                   users#update
                       PUT    /users/:id(.:format)                   users#update
                       DELETE /users/:id(.:format)                   users#destroy
         user_password POST   /users/password(.:format)              devise/passwords#create
     new_user_password GET    /users/password/new(.:format)          devise/passwords#new
    edit_user_password GET    /users/password/edit(.:format)         devise/passwords#edit
                       PATCH  /users/password(.:format)              devise/passwords#update
                       PUT    /users/password(.:format)              devise/passwords#update
 new_user_registration GET    /signup(.:format)                      devise/registrations#new
     user_registration POST   /signup(.:format)                      devise/registrations#create
      new_user_session GET    /login(.:format)                       devise/sessions#new
          user_session POST   /login(.:format)                       devise/sessions#create
  destroy_user_session DELETE /logout(.:format)                      devise/sessions#destroy
              practice GET    /practice/:id(.:format)                exercises#practice
              evaluate PATCH  /practice/:id(.:format)                exercises#evaluate
      calc_performance GET    /users/:id/performance(.:format)       users#calc_performance
                search POST   /exercises/search(.:format)            exercises#search

=end
