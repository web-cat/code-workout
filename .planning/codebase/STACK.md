# Technology Stack

## Core Technologies
- **Language:** Ruby (via `Gemfile`)
- **Framework:** Ruby on Rails (~> 5.1)
- **Database:** MariaDB (per project overview, uses `mysql2` gem)
- **Frontend Stack:** HTML/Haml (`haml-rails`), CSS/Sass (`sass-rails`, `bootstrap-sass`), JavaScript/CoffeeScript (`coffee-rails`)

## Key Libraries & Dependencies
- **Authentication:** Devise, OmniAuth (Facebook, Google, CAS)
- **Authorization:** CanCanCan
- **Admin Interface:** ActiveAdmin
- **Asynchronous Processing:** Sucker Punch (`sucker_punch`)
- **Testing:** RSpec (`rspec-rails`), Capybara, FactoryBot (`factory_bot_rails`), Test::Unit
- **Code Editor Components:** CodeMirror (`codemirror-rails`)
- **JSON Processing:** Rabl, Oj

## Deployment & Server
- **Web Server:** Puma (Production/Staging), Thin (Development)
- **Deployment Strategy:** Capistrano with Capistrano-Puma
- **Environment:** Dockerized setup (indicated by project details and `docker-compose.yml`)
