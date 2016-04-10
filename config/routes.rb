CodeWorkout::Application.routes.draw do

  root 'home#index'

  post 'lti/launch' => 'workout_offerings#practice', as: :lti_workout_offering_practice

  post 'lti/assessment'

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
    resources :exercises

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
    get ':course_id/:term_id/:id/practice(/:exercise_id)' => 'workout_offerings#practice', as: :workout_offering_practice
    get ':course_id/:term_id/:workout_offering_id/:id' => 'exercises#practice', as: :workout_offering_exercise
    patch ':course_id/:term_id/:workout_offering_id/:id' => 'exercises#evaluate', as: :workout_offering_exercise_evaluate
    get ':course_id/:term_id/:workout_offering_id/review/:review_user_id/:id' => 'exercises#practice', as: :workout_offering_exercise_review
    get ':course_id/:term_id/:id' => 'workout_offerings#show', as: :workout_offering
    get ':course_id/:term_id/review/:review_user_id/:id' => 'workout_offerings#review', as: :workout_offering_review
    post ':id/:term_id/generate_gradebook/' => 'courses#generate_gradebook', as: :course_gradebook
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