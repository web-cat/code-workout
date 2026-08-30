
# Plan for Implementing Student Deadline Extensions

This document outlines the plan to incorporate student-specific deadline extensions for workouts, inspired by the implementation in the OpenDSA-LTI project.

## 1. Database Migration

A new database table, `student_extensions`, will be created to store extension data.

- **Action:** Create a new Rails migration file.
- **Table Name:** `student_extensions`
- **Columns:**
    - `user_id` (integer, foreign key to `users` table)
    - `workout_offering_id` (integer, foreign key to `workout_offerings` table)
    - `hard_deadline` (datetime)
    - `soft_deadline` (datetime)
    - `time_limit` (integer, in minutes)
- **Indexes:** Add indexes on `user_id` and `workout_offering_id` for efficient lookups.

## 2. Model Creation and Modification

New models will be created and existing models will be modified to handle the extension logic.

- **Action:** Create a new model file: `app/models/student_extension.rb`.
    - This model will belong to a `User` and a `WorkoutOffering`.
- **Action:** Modify `app/models/workout_offering.rb`.
    - Add a `has_many :student_extensions` association.
    - Create an `effective_deadline(user)` method. This method will check if a `StudentExtension` exists for the given user. If it does, it will return the extension's deadline; otherwise, it will return the workout offering's default deadline.
- **Action:** Modify `app/models/attempt.rb`.
    - Update the logic that checks if an attempt is late to use the `effective_deadline` from the associated `WorkoutOffering`.

## 3. Controller Implementation

New controllers will be created to manage extensions through a RESTful API.

- **Action:** Create a new controller file: `app/controllers/api/v1/student_extensions_controller.rb`.
- **Controller Name:** `Api::V1::StudentExtensionsController`
- **Actions:**
    - `create`: To create a new extension for a student and a workout offering.
    - `update`: To modify an existing extension.
    - `destroy`: To remove an extension.
- **Authentication:** The controller will need to be protected to ensure only authorized users (instructors or admins) can manage extensions.

## 4. Routing

Routes will be added to expose the new API endpoints.

- **Action:** Modify `config/routes.rb`.
- **Routes:**
    - Create a new `namespace :api` and `namespace :v1` block.
    - Add `resources :student_extensions, only: [:create, :update, :destroy]` within the `v1` namespace.

## 5. API Documentation

The new API endpoints will be documented to describe their functionality.

- **Endpoint:** `POST /api/v1/student_extensions`
    - **Body:** `{ "user_id": <user_id>, "workout_offering_id": <workout_offering_id>, "hard_deadline": "<datetime>" }`
- **Endpoint:** `PUT /api/v1/student_extensions/:id`
    - **Body:** `{ "hard_deadline": "<new_datetime>" }`
- **Endpoint:** `DELETE /api/v1/student_extensions/:id`
