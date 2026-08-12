# Coding Conventions

## Core Methodology: Get Shit Done (GSD)
- **Drive by Specification:** No code is written before `.gsd/SPEC.md` is FINALIZED.
- **Atomic Commits:** Implementation occurs with one task per commit (format `type(scope): description`). Example: `feat(phase-1): Add user login`.
- **Search-First Discipline:** Always search (`grep`/`ripgrep`) before reading entire files to manage context window pollution.
- **Empirical Verification:** Never accept "it should work." Every change requires proof (e.g., test output, `curl` result, UI screenshot) prior to commit.

## Code Style & Patterns
- **Ruby on Rails Standards:** Adheres to conventional Rails naming and structural guidelines (Fat Models, Skinny Controllers).
- **GSD Meta-Prompting System:**
  - Files are meant to teach AI how to build systematically.
  - Optimize for solo developer + AI workflow.
  - Plans (`PLAN.md`) are executable.
- **XML Tag Usage:** Use XML tags (`<role>`, `<process>`, `<task>`) for semantic meaning in documentation and prompts, not for formatting.
