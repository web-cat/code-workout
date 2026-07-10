# Testing Practices

## Framework & Structure
- **Core Framework:** RSpec (`rspec-rails`) is the primary testing tool. Capybara is used for integration/UI testing.
- **Directory Layout:** Tests are located in `spec/` mirroring the `app/` structure:
  - `controllers/`
  - `models/`
  - `requests/` (Integration/routing tests)
  - `routing/`
  - `views/`
- **Factories:** FactoryBot (`factory_bot_rails`) definitions are placed under `spec/factories/` to generate test data.
- **Configuration:** Main setup in `spec/spec_helper.rb`.

## Testing Philosophy (GSD-driven)
- **Required Verification:** Every change requires verification evidence. Tests are not optional.
- **Task Proof:** Test runner output is acceptable empirical proof for "done" acceptance criteria across tasks.
