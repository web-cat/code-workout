CodeWorkout::Application.routes.draw do



  ActiveAdmin.routes(self)
  root 'home#index'

  get 'home' => 'home#index'
  get 'main' => 'home#index'
  get 'home/about'
  get 'home/license'
  get 'home/contact'

  get 'static_pages/home'
  get 'static_pages/help'
  get 'static_pages/mockup1'
  get 'static_pages/mockup2'
  get 'static_pages/mockup3'
  get 'static_pages/typography'

  get 'exercises/upload' => 'exercises#upload', as: :exercises_upload
  get 'exercises/download' => 'exercises#download', as: :exercises_download
  post 'exercises/upload_create' => 'exercises#upload_create'
  get 'exercises/upload_mcqs' => 'exercises#upload_mcqs',
    as: :exercises_upload_mcqs
  post 'exercises/create_mcqs' => 'exercises#create_mcqs'

  get 'workouts/:id/add_exercises' => 'workouts#add_exercises'
  post 'workouts/link_exercises'  => 'workouts#link_exercises'
  post '/coding_questions' => 'exercises#create'
  get 'workouts/download' => 'workouts#download'
  get '/gym' => 'workouts#gym', as: :gym

  resources :exercises
  resources :coding_problems

  resources :course_offerings

  resources :courses
  resources :organizations
  resources :languages
  resources :tags
  resources :course_enrollments

  resources :organizations
  resources :course_roles
  resources :global_roles
  resources :terms
  # TODO: Might enable scaffolding pages later. Disabled till Fall. Being manually added till now.
  #resources :languages
  #resources :tags
  #resources :choices
  #resources :stems


  resources :course_enrollments
  resources :users
  resources :resource_files
  resources :workouts
  resources :signups


  #OmniAuth for Facebook
  devise_for :users,
    controllers: { omniauth_callbacks: 'users/omniauth_callbacks' },
    skip: [:registrations, :sessions]
  as :user do
    get '/signup' => 'devise/registrations#new', as: :new_user_registration

    # TODO: These routes are broken and need to be fixed!
    get '/about' => 'devise/about#new', as: :about_page
    get '/license' => 'devise/license#new', as: :license_page
    get '/contact' => 'devise/contact#new', as: :contact_page
    post '/courses/:id/generate_gradebook' => 'courses#generate_gradebook', as: :course_gradebook
    post '/course_offerings/:id/generate_gradebook' => 'course_offerings#generate_gradebook', as: :course_offering_gradebook
    #post '/exercises/:id/update' => 'exercise#update', as: :exercise_update
    get '/exercises_random_exercise' => 'exercises#random_exercise', as: :random_exercise
    get '/courses_search' => 'courses#search', as: :courses_search
    post '/courses_find' => 'courses#find', as: :course_find
    get '/workouts/new_with_search/:searchkey'  => 'workouts#new_with_search', as: :workouts_with_search
    post '/workouts/new_with_search'  => 'workouts#new_with_search', as: :workouts_exercise_search
    post '/signup' => 'devise/registrations#create', as: :user_registration
    get '/login' => 'devise/sessions#new', as: :new_user_session
    post '/login' => 'devise/sessions#create', as: :user_session
    delete '/logout' => 'devise/sessions#destroy', as: :destroy_user_session
    get '/practice_workout/:id' => 'workouts#practice_workout', as: :practice_workout
    get '/practice/:id' => 'exercises#practice', as: :exercise_practice
    get '/course_offerings/:id/add_workout' => 'course_offerings#add_workout', as: :course_offering_add_workout
    post '/course_offerings/store_workout/:id' => 'course_offerings#store_workout', as: :course_offering_store_workout
    patch '/practice/:id' => 'exercises#evaluate', as: :exercise_evaluate
    get '/workouts/:id/evaluate' => 'workouts#evaluate', as: :workout_evaluate
    get '/users/:id/performance' => 'users#calc_performance', as: :calc_performance
    post '/exercises/search' => 'exercises#search', as: :search
    post 'resource_files/uploadFile' => 'resource_files#uploadFile'
  end

  match 'course_offering/:course_offering_id/upload_roster/:action',
    controller: 'upload_roster', as: 'upload_roster', via: [:get, :post]

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
