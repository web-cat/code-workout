# System Architecture

## Architectural Pattern
- **MVC (Model-View-Controller):** Standard Ruby on Rails application structure.

## Core Domain Models
- **Users & Identities:** `User`, `Identity`, `GlobalRole`, `CourseRole`, `LtiIdentity`
- **Courses & Offerings:** `Course`, `CourseOffering`, `Term`, `Organization`
- **Exercises & Assessments:** `Exercise`, `ExerciseVersion`, `Prompt` (and its STI subclasses `CodingPrompt`, `MultipleChoicePrompt`), `Workout`, `WorkoutOffering`
- **Student Engagement:** `Attempt`, `WorkoutScore`, `TestCaseResult`

## Data Flow
- **Request Lifecycle:** Handled via standard Rails routing -> controllers -> views/JSON rendering.
- **Asynchronous Execution:** Background jobs implemented with Sucker Punch (`sucker_punch` gem) for tasks that don't need immediate synchronous responses (e.g., potentially grading or emails).

## Key Subsystems
- **LTI Integration:** Plugs into the LMS ecosystem as a tool provider, processing LTI launch requests and passing back grades.
- **Grading Engine:** Evaluates student submitted code against defined `TestCase` models.
