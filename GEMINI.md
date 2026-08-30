# CodeWorkout Project

## Project Overview

CodeWorkout is a web-based platform built with Ruby on Rails, designed to help users learn programming. It provides a space for users to practice coding exercises and multiple-choice questions, receiving immediate feedback. The platform supports both self-paced learning and structured courses for instructors.

The application uses a MariaDB database and is set up to run in a Dockerized environment. Key features include user authentication, course management, exercise creation, and a "gym" for practicing workouts.

## Building and Running

The project can be run in a Dockerized environment for services (like MariaDB), but all Rails and Rake commands should be executed locally using **RVM** with the Ruby version specified in `.ruby-version` (currently **2.7.0**).

* **Run database migrations:**
```bash
  rvm 2.7.0 do bundle exec rake db:migrate
```
* **Seed data:**
```bash
  rvm 2.7.0 do bundle exec rake db:populate
```
* **Run the Rails server:**
```bash
  rvm 2.7.0 do bundle exec bin/rails s
```
* **Access the running application:**
  [http://localhost:3000](http://localhost:3000) (or the port specified in your local environment)

## Development Conventions

* **Ruby Version:** Always use `rvm 2.7.0 do <command>` to ensure consistency.
* **Dependencies:** Ruby gems are managed by `Bundler` and are listed in the `Gemfile`.
* **Database:** The database schema is defined in `db/schema.rb`. Migrations are used for schema changes. On any database connection error, ask the user to confirm the database is currently running before attempting to fix anything.
* **Type-Agnostic Migrations:** To ensure compatibility between legacy servers (using `integer` PKs) and modern environments (using `bigint` PKs), all new migrations must use a helper to detect the referenced column's type.
```ruby
  def fk_type(table)
    column = ActiveRecord::Base.connection.columns(table).find { |c| c.name == 'id' }
    column.sql_type.include?('bigint') ? :bigint : :integer
  rescue
    :bigint
  end

  # Use it like this:
  add_column :my_table, :user_id, fk_type(:users)
  # Or with references:
  t.references :user, type: fk_type(:users), foreign_key: true
```
* **Testing:** The project uses RSpec for testing. Test files are located in the `spec` directory.
* **Routing:** Application routes are defined in `config/routes.rb`.
