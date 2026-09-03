# Application Package — AI Coding Agent Guide

## Project Specific Rules

- This package provides shared app-level orchestration, lifecycle support, state modeling, and change monitoring for SwiftUI applications.
- Target macOS 26.0+, iOS 26.0+, and tvOS 26.0+.
- The codebase uses Swift 6.2 with modern concurrency.
- Regular package targets default to `MainActor` isolation. Keep executor assumptions explicit and avoid accidental cross-actor access.

## Standard Rules

- Always write good code and keep behavior, tests, and docs aligned.
- Use red/green TDD for non-UI code.
- Create previews for UI code.
- Apply DRY and single-source-of-truth rules, and prefer KISS, YAGNI, make-illegal-states-unrepresentable, explicit dependencies, composition over inheritance, command-query separation, least knowledge, structured concurrency, design by contract, and idempotency.
- Prefer minimal, focused changes that solve the requested problem.
- Prefer fixing root causes over layered workarounds.
- Modernise or adopt a new architecture/style if appropriate, but avoid leaving mixed styles behind without a clear reason.
- Understand request boundaries, inspect relevant code/docs before editing, apply the smallest coherent change set, add or update tests for behavior changes, run relevant validation checks, and report changes, validation status, and residual risks.
- Use the `swift-validation` skill for standard validation when it applies. If a check cannot be run, say so and explain why.
- Prioritize correctness, clarity, and maintainability.
- Keep interfaces explicit and intentionally small.
- Avoid hidden coupling and surprising side effects.
- Do not add dependencies without clear justification.
- Never expose or commit credentials or secrets.
- Use trusted primary sources for technical decisions and external references, following ~/.local/share/agents/references/Trusted Sources.md.
- Follow ~/.local/share/agents/references/COMMON.md, ~/.local/share/agents/references/Good Code.md, ~/.local/share/agents/references/Principles.md, and ~/.local/share/agents/references/languages/Swift.md.
- Use ~/.local/share/skills/SwiftUI-Agent-Skill/swiftui-pro/SKILL.md for SwiftUI-specific guidance, ~/.local/share/skills/Swift-Concurrency-Agent-Skill/swift-concurrency-pro/SKILL.md for concurrency decisions, and ~/.local/share/skills/Swift-Testing-Agent-Skill/swift-testing-pro/SKILL.md for Swift Testing guidance.
- Use ~/.local/share/skills/codex-git-skill/SKILL.md for git operations and ~/.local/share/skills/codex-github-skill/SKILL.md for GitHub workflows.
- Do not perform irreversible destructive actions without explicit approval.
- Avoid unrelated refactors during focused tasks.
- If unexpected workspace changes appear, pause and confirm direction.
- For `gh` commands with Markdown bodies, use `--body-file` rather than inline `--body`.
- Keep PR summaries factual, scoped to the diff, and include validation and any gaps.
- Add compact documentation comments for each type, method or function, and member or property describing purpose.
- Comments should add intent or context, not restate names.
- For the primary type in a source file, add a top-level documentation comment with design or implementation detail.
- Keep inline comments sparse and focused on subtle logic or constraints.

To refresh this file, use the ~/.local/share/skills/refresh-agents-skill/SKILL.md skill.
