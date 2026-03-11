# Directory Layout

## Root Directories (Standard Rails structure)
- `app/`: Source code for the application.
  - `controllers/`: Request handlers.
  - `models/`: Database-backed models and business logic.
  - `views/`: HTML/Haml templates.
  - `helpers/`: View helper modules.
  - `assets/`: Static assets (CSS/Sass, JavaScript/CoffeeScript, images).
  - `admin/`: ActiveAdmin configuration files.
  - `mailers/`: Email delivery classes.
- `config/`: Application configuration, environment settings, initializers, and `routes.rb`.
- `db/`: Database schema (`schema.rb`), migrations, and seeds.
- `lib/`: Custom Ruby modules, extensions, and potentially the grading code execution logic.
- `spec/`: RSpec test suite.
- `public/`: Publicly accessible static files.
- `vendor/`: Third-party assets or gems not managed by Bundler.

## Project-Specific & Infrastructure Directories
- `.gsd/`: Get Shit Done methodology state and artifacts (Spec, Roadmap, State).
- `.agent/`, `.agents/`: Agent workflows and skills documentation.
- `docker-compose.yml`, `Dockerfile`, `docker-run.sh`: Docker environment configuration files for isolated execution/development.
