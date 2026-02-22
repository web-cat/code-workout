
# CodeWorkout Project

## Project Overview

CodeWorkout is a web-based platform built with Ruby on Rails, designed to help users learn programming. It provides a space for users to practice coding exercises and multiple-choice questions, receiving immediate feedback. The platform supports both self-paced learning and structured courses for instructors.

The application uses a MariaDB database and is set up to run in a Dockerized environment. Key features include user authentication, course management, exercise creation, and a "gym" for practicing workouts.

## Building and Running

The project uses Docker to manage its development environment. The following commands are essential for getting the application running:

*   **Build and start the application:**
    ```bash
    docker-compose up -d
    ```
*   **Stop the application:**
    ```bash
    docker-compose down
    ```
*   **Run database migrations and seed data:**
    ```bash
    docker-compose run web rake db:populate
    ```
*   **Access the running application:**
    [https://localhost:9292](https://localhost:9292)

## Development Conventions

*   **Dependencies:** Ruby gems are managed by `Bundler` and are listed in the `Gemfile`.
*   **Database:** The database schema is defined in `db/schema.rb`. Migrations are used for schema changes.
*   **Testing:** The project uses RSpec for testing. Test files are located in the `spec` directory.
*   **Routing:** Application routes are defined in `config/routes.rb`.
*   **Docker:** The Docker environment is configured in `docker-compose.yml` and the `Dockerfile`.
