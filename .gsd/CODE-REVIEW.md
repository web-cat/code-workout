# Code Review & Architectural Analysis

> Detailed review of architectural weaknesses, MVC concerns, database performance bottlenecks, and general code smells discovered in the CodeWorkout codebase.

## Architectural Weaknesses

1. **Fat Controllers & Violation of Single Responsibility Principle**
   - The controllers are handling too much business logic, rather than just handling HTTP requests and delegating to service objects or models. 
   - Most notably:
     - `app/controllers/exercises_controller.rb` (1,138 lines)
     - `app/controllers/workouts_controller.rb` (1,052 lines)
     - `app/controllers/course_offerings_controller.rb` (371 lines)
   - **Recommendation:** Implement a Service Object pattern (e.g., placing complex interaction logic in `app/services/`) and a Form Object pattern for complex creations to thin out these controllers.

2. **Fat Models (God Objects)**
   - Several ActiveRecord models have grown exceedingly large, centralizing too much logic.
   - Most notably:
     - `app/models/user.rb` (1,003 lines)
     - `app/models/exercise.rb` (633 lines)
     - `app/models/coding_prompt.rb` (632 lines)
     - `app/models/workout_score.rb` (517 lines)
   - **Recommendation:** Extract logic into ActiveSupport Concerns (e.g., `app/models/concerns/`) or move calculations out of the model layer entirely into Service or Policy objects.

3. **Background Job Parsing Vulnerabilities**
   - In `app/jobs/code_worker.rb` and `app/utils/peml_parsing_util.rb`, text extraction and code evaluation occur with numerous `FIXME`s related to regex/parsing (e.g., failing to support C++ line number extraction). 
   - Additionally, compiling/running arbitrary student code needs extreme isolation (though there is Docker integration, the worker parsing layer is brittle).
   - **Recommendation:** Overhaul the compilation output parsing to use structured data (JSON/XML) if the code runner supports it, rather than brittle Regex string manipulation.

## MVC Concerns

1. **Logic Bleeding into Views**
   - Views (e.g. `_tab_grades.html.haml`) contain documented "Funky logic".
   - **Recommendation:** Utilize MVP (Model-View-Presenter) decorators or HTML helpers to isolate display formatting from the view templates.

2. **Authentication/Authorization Scattered**
   - While Cancancan is used (`ability.rb`), permissions are described as "too broad" or "using a kludge" (e.g., `workout_offering.rb`).
   - Standard Rails `before_action` auth checks are likely intermingled with domain rules.

## Database query concerns

1. **N+1 Query Risks**
   - Extensive investigation of the controllers shows that `includes`, `joins`, `preload`, or `eager_load` are **rarely** used to optimize ActiveRecord relation fetching.
   - They appear occasionally in `organizations_controller.rb` and `workouts_controller.rb`, but are completely absent from heavily loaded controllers like `exercises_controller.rb` and `course_offerings_controller.rb`. Given these controllers load many relations (Exercises, Prompts, Test Cases, Workout Scores), N+1 queries are highly probable during rendering.
   - **Recommendation:** Introduce Bullet gem in development to automatically catch N+1 queries, and aggressively add `.includes()` to index actions.

2. **Inadequate Indexing**
   - Evaluating the database schema (`db/schema.rb`) reveals only around **60 explicit indexes** for a system with 50+ models and massive join tables (e.g., workouts to exercises, attempts to prompts). 
   - Without compound indexes on heavily queried relations (like `[user_id, workout_id]`), the system will face severe performance degradation under concurrent classroom load.
   - **Recommendation:** Review slow-query logs in Mariadb and apply indexing to all foreign keys and commonly searched boolean/status fields.

## Security Code-Smell check

1. **Defunct CarrierWave File Management**
   - The `ResourceFile` model leaves unused/unclosed tempfiles on the system (`FIXME: need to close the tempfile and delete it`). This can eventually lead to disk exhaustion or Denial of Service (DoS).
   - **Recommendation:** Clean up file cleanup routines in `ensure` blocks.

2. **CSV and Mass Assignment Weaknesses**
   - `course_offerings_controller.rb` has logic meant for CSV parsing that is incomplete. Improper parsing of user-uploaded files (like CSV rosters or PEML exercises) introduces vectors for CSV injection.
