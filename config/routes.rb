CodeWorkout::Application.routes.draw do

  root 'static_pages#home'

  get "static_pages/home"
  get "static_pages/help"
  get "static_pages/mockup1"
  get "static_pages/mockup2"
  get "static_pages/mockup3"

  resources :course_offerings
  resources :terms
  resources :courses
  resources :organizations

end
