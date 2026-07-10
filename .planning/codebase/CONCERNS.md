# Technical Debt & Issues

## Current Concerns
- **Docker Mount Issues:** Active issue seen in `err.log` where Docker volume bindings fail (`invalid volume specification: [...] invalid mount path: 'usr/attempts/active/869' mount path must be absolute`). This affects the test execution environment.
- **Ruby Syntax Errors in Student Submissions/Tests:** The `err.log` shows runtime parsing exceptions (e.g., `unexpected tIDENTIFIER, expecting keyword_end`). While possibly a specific student submission issue, error handling for user-provided code might need hardening.
- **Schema & Migration Conflicts:** Notes mention frequent merge conflicts in `db/schema.rb` and a preference for `rake db:schema:load` over migrations due to "stale" migrations. Handling over 100 historical migrations indicates significant accrued database schema maturity/debt.
- **File Exists/Missing Errors:** `bash: /resources/run.sh: No such file or directory` noted in errors, pointing to potential container filesystem mapping or missing script issues.
- **Merge Conflicts in Models:** Frequent conflicts noted in core models like `workout_score.rb`, `workout_offering.rb`, `workout.rb`, `attempt.rb`. This suggests overlapping work or a need for refactoring "Fat Models" into smaller service objects.

## Infrastructure
- **Deployment Complexity:** Instructions mention both Docker Compose and bare-metal (Capistrano) deployments.
