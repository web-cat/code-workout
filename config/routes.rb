CodeWorkout::Application.routes.draw do

  

  resources :workouts

  root 'static_pages#home'

  get "static_pages/home"
  get "static_pages/help"
  get "static_pages/mockup1"
  get "static_pages/mockup2"
  get "static_pages/mockup3"

  #resources :exercises, shallow: true do
  #  resources :choices  
  #end  
  resources :exercises 
  resources :choices
  resources :stems
  resources :course_offerings
  resources :terms
  resources :courses
  resources :organizations
  resources :languages  
  resources :tags  
  resources :course_enrollments
  resources :course_roles
  resources :global_roles
  resources :course_enrollments
  resources :course_roles
  resources :users

  devise_for :users, :skip => [:registrations, :sessions]
  as :user do
    get "/signup" => "devise/registrations#new", as: :new_user_registration
    post "/signup" => "devise/registrations#create", as: :user_registration
    get "/login" => "devise/sessions#new", as: :new_user_session
    post "/login" => "devise/sessions#create", as: :user_session
    delete "/logout" => "devise/sessions#destroy", as: :destroy_user_session
    get '/practice/:id' => 'exercises#practice', as: :practice
    patch '/practice/:id' => 'exercises#evaluate', as: :evaluate
    get '/users/:id/performance' => 'users#calc_performance', as: :calc_performance
  end

end
#== Route Map
# Generated on 14 Sep 2013 22:31
#
#             course_roles GET    /course_roles(.:format)              course_roles#index
#                          POST   /course_roles(.:format)              course_roles#create
#          new_course_role GET    /course_roles/new(.:format)          course_roles#new
#         edit_course_role GET    /course_roles/:id/edit(.:format)     course_roles#edit
#              course_role GET    /course_roles/:id(.:format)          course_roles#show
#                          PATCH  /course_roles/:id(.:format)          course_roles#update
#                          PUT    /course_roles/:id(.:format)          course_roles#update
#                          DELETE /course_roles/:id(.:format)          course_roles#destroy
#         new_user_session GET    /users/sign_in(.:format)             devise/sessions#new
#             user_session POST   /users/sign_in(.:format)             devise/sessions#create
#     destroy_user_session DELETE /users/sign_out(.:format)            devise/sessions#destroy
#            user_password POST   /users/password(.:format)            devise/passwords#create
#        new_user_password GET    /users/password/new(.:format)        devise/passwords#new
#       edit_user_password GET    /users/password/edit(.:format)       devise/passwords#edit
#                          PATCH  /users/password(.:format)            devise/passwords#update
#                          PUT    /users/password(.:format)            devise/passwords#update
# cancel_user_registration GET    /users/cancel(.:format)              devise/registrations#cancel
#        user_registration POST   /users(.:format)                     devise/registrations#create
#    new_user_registration GET    /users/sign_up(.:format)             devise/registrations#new
#   edit_user_registration GET    /users/edit(.:format)                devise/registrations#edit
#                          PATCH  /users(.:format)                     devise/registrations#update
#                          PUT    /users(.:format)                     devise/registrations#update
#                          DELETE /users(.:format)                     devise/registrations#destroy
#                     root GET    /                                    static_pages#home
#        static_pages_home GET    /static_pages/home(.:format)         static_pages#home
#        static_pages_help GET    /static_pages/help(.:format)         static_pages#help
#     static_pages_mockup1 GET    /static_pages/mockup1(.:format)      static_pages#mockup1
#     static_pages_mockup2 GET    /static_pages/mockup2(.:format)      static_pages#mockup2
#     static_pages_mockup3 GET    /static_pages/mockup3(.:format)      static_pages#mockup3
#         course_offerings GET    /course_offerings(.:format)          course_offerings#index
#                          POST   /course_offerings(.:format)          course_offerings#create
#      new_course_offering GET    /course_offerings/new(.:format)      course_offerings#new
#     edit_course_offering GET    /course_offerings/:id/edit(.:format) course_offerings#edit
#          course_offering GET    /course_offerings/:id(.:format)      course_offerings#show
#                          PATCH  /course_offerings/:id(.:format)      course_offerings#update
#                          PUT    /course_offerings/:id(.:format)      course_offerings#update
#                          DELETE /course_offerings/:id(.:format)      course_offerings#destroy
#                    terms GET    /terms(.:format)                     terms#index
#                          POST   /terms(.:format)                     terms#create
#                 new_term GET    /terms/new(.:format)                 terms#new
#                edit_term GET    /terms/:id/edit(.:format)            terms#edit
#                     term GET    /terms/:id(.:format)                 terms#show
#                          PATCH  /terms/:id(.:format)                 terms#update
#                          PUT    /terms/:id(.:format)                 terms#update
#                          DELETE /terms/:id(.:format)                 terms#destroy
#                  courses GET    /courses(.:format)                   courses#index
#                          POST   /courses(.:format)                   courses#create
#               new_course GET    /courses/new(.:format)               courses#new
#              edit_course GET    /courses/:id/edit(.:format)          courses#edit
#                   course GET    /courses/:id(.:format)               courses#show
#                          PATCH  /courses/:id(.:format)               courses#update
#                          PUT    /courses/:id(.:format)               courses#update
#                          DELETE /courses/:id(.:format)               courses#destroy
#            organizations GET    /organizations(.:format)             organizations#index
#                          POST   /organizations(.:format)             organizations#create
#         new_organization GET    /organizations/new(.:format)         organizations#new
#        edit_organization GET    /organizations/:id/edit(.:format)    organizations#edit
#             organization GET    /organizations/:id(.:format)         organizations#show
#                          PATCH  /organizations/:id(.:format)         organizations#update
#                          PUT    /organizations/:id(.:format)         organizations#update
#                          DELETE /organizations/:id(.:format)         organizations#destroy
