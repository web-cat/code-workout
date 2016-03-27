CodeWorkout::Application.routes.draw do

  root 'home#index'

  get 'home' => 'home#index'
  get 'main' => 'home#index'
  get 'home/about'
  get 'home/license'
  get 'home/contact'
  get 'home/new_course_modal', as: :new_course_modal

  get 'static_pages/home'
  get 'static_pages/help'
  get 'static_pages/mockup1'
  get 'static_pages/mockup2'
  get 'static_pages/mockup3'
  get 'static_pages/typography'
  get 'static_pages/thumbnails'
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

  #for the Q&A forum
  resources :questions
  resources :responses

  get 'sse/feedback_wait'
  # get 'sse/feedback_update'
  get 'sse/feedback_poll'
  post '/course_offerings/:id/upload_roster' => 'course_offerings#upload_roster'

  get '/request_extension' => 'workout_offerings#request_extension'
  post '/add_extension' => 'workout_offerings#add_extension'

  # All of the routes anchored at /gym
  scope :gym do
    # The top-level gym route
    get '/' => 'workouts#gym', as: :gym

    # /gym/exercises ...
    get  'exercises_import' => 'exercises#upload_yaml'
    post  'exercises_yaml_create' => 'exercises#yaml_create'
    get  'exercises/upload' => 'exercises#upload', as: :exercises_upload
    get  'exercises/download' => 'exercises#download', as: :exercises_download
    post 'exercises/upload_create' => 'exercises#upload_create'
    get  'exercises/upload_mcqs' => 'exercises#upload_mcqs',
      as: :exercises_upload_mcqs
    post 'exercises/create_mcqs' => 'exercises#create_mcqs'
    get  '/exercises/any' => 'exercises#random_exercise',
      as: :random_exercise
    get 'exercises/:id/practice' => 'exercises#practice',
      as: :exercise_practice
    patch 'exercises/:id/practice' => 'exercises#evaluate',
      as: :exercise_evaluate
    post 'exercises/search' => 'exercises#search', as: :search
    # At the bottom, so the routes above take precedence over existing ids
    
    resources :exercises do
      resources :questions, :only => [:new]
    end

    # /gym/workouts ...
    get  'workouts/download' => 'workouts#download'
    get  'workouts/:id/add_exercises' => 'workouts#add_exercises'
    post 'workouts/link_exercises'  => 'workouts#link_exercises'
    get  'workouts/new_with_search/:searchkey'  => 'workouts#new_with_search',
      as: :workouts_with_search
    post 'workouts/new_with_search'  => 'workouts#new_with_search',
      as: :workouts_exercise_search
    get  'workouts/:id/practice' => 'workouts#practice',
      as: :practice_workout
    get  'workouts/:id/evaluate' => 'workouts#evaluate', as: :workout_evaluate
    get  'workouts_dummy' => 'workouts#dummy'
    get  'workouts_import' => 'workouts#upload_yaml'
    post  'workouts_yaml_create' => 'workouts#yaml_create'

    # At the bottom, so the routes above take precedence over existing ids
    resources :workouts
  end

  # All of the routes anchored at /courses
  resources :organizations, only: [ :index, :show ], path: '/courses' do
    get 'search' => 'courses#search', as: :courses_search
    post 'find' => 'courses#find', as: :course_find
    get 'new' => 'courses#new'
    get ':id/edit' => 'courses#edit', as: :course_edit
    get ':course_id/:term_id/:id/practice(/:exercise_id)' =>
      'workout_offerings#practice',
      as: :workout_offering_practice
    get ':course_id/:term_id/:workout_offering_id/:id' => 'exercises#practice',
      as: :workout_offering_exercise
    patch ':course_id/:term_id/:workout_offering_id/:id' => 'exercises#evaluate',
      as: :workout_offering_exercise_evaluate
    get ':course_id/:term_id/:workout_offering_id/review/:review_user_id/:id' => 'exercises#practice',
      as: :workout_offering_exercise_review  

    get ':course_id/:term_id/:id' => 'workout_offerings#show',
      as: :workout_offering
    get ':course_id/:term_id/review/:review_user_id/:id' => 'workout_offerings#review',
      as: :workout_offering_review  
    post ':id/:term_id/generate_gradebook/' => 'courses#generate_gradebook',
      as: :course_gradebook
    get ':id(/:term_id)' => 'courses#show', as: :course


  end


  resources :course_offerings, only: [ :edit, :update ] do
    post 'enroll' => :enroll, as: :enroll
    delete 'unenroll' => :unenroll, as: :unenroll
    match 'upload_roster/:action', controller: 'upload_roster',
      as: :upload_roster, via: [:get, :post]
    post 'generate_gradebook' => :generate_gradebook, as: :gradebook
    get 'add_workout' => :add_workout, as: :add_workout
    post 'store_workout/:id' => :store_workout, as: :store_workout
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
    controllers: { omniauth_callbacks: 'users/omniauth_callbacks' },
    skip: [:registrations, :sessions]
  as :user do
    get '/signup' => 'devise/registrations#new', as: :new_user_registration
    post '/signup' => 'devise/registrations#create', as: :user_registration
    get '/login' => 'devise/sessions#new', as: :new_user_session
    post '/login' => 'devise/sessions#create', as: :user_session
    delete '/logout' => 'devise/sessions#destroy', as: :destroy_user_session
  end

end
#== Route Map
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
