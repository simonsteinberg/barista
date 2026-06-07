# Barista Agent — CLAUDE.md

## Additional instructions

- [.agent/SOFTWARE_ENGINEERING.md](.agent/SOFTWARE_ENGINEERING.md) — the reasoning ("why") behind the rules in this file. Read it alongside this checklist; when the two appear to conflict, this file is the operational source of truth.
- [docs/DESIGN_AND_REQUIREMENTS.md](docs/DESIGN_AND_REQUIREMENTS.md) — the current design and requirements of the system. Treat it as the authoritative description of *what* is being built and *why*.
- [.agent/VERSIONING.md](.agent/VERSIONING.md) — the full versioning and release policy (SemVer scheme, release tooling, changelog discipline, and how to retire a vulnerable version). The operational checklist lives in [Versioning and Releases](#versioning-and-releases) below; that doc is the "why" and the full detail.

**Keep [docs/DESIGN_AND_REQUIREMENTS.md](docs/DESIGN_AND_REQUIREMENTS.md) current.** Whenever a session changes design or requirements — new or altered requirements, a different architecture or component boundary, a changed data model, or a non-trivial trade-off decision — update that doc in the same change so it never drifts from the code. If a session does not affect design or requirements, leave it untouched.

## Standard procedure (default implementation workflow)

**This is the default way to implement any change** — a bug fix, a new feature, a chore, a refactor, and so on. Follow it in full whenever you are told to use the **"standard procedure"**, to **"make a plan first"**, or whenever a task amounts to a unit of work that lands on `main`. If you are genuinely unsure whether a task warrants the full procedure (for example a one-line typo fix), **ask the user** rather than guessing.

Run these steps in order:

1. **Open a GitHub issue** for the work — `gh issue create` with a clear title and summary. Note the issue number; you reference it from the PR.
2. **Create a git worktree on a new feature branch**, branched from an up-to-date `main`, under `.worktree/<slug>` (see [Git worktrees](#git-worktrees)): `git worktree add .worktree/<slug> -b <type>/<slug> main`.
3. **Draft an implementation plan** before writing any code.
4. **Resolve every unknown with the user — never assume.** If anything about scope, requirements, or design is unclear or underspecified, ask the user, and **offer predefined answer options** so the choice is concrete. Only proceed once the plan is unambiguous. (For a new agentic workflow, also create its scoped specification/plan/README docs first — see [Agentic AI — new workflow checklist](#agentic-ai--new-workflow-checklist).)
5. **Implement** the change — the smallest change that fully solves the task, following the design, code-style, and testing rules in this file (TDD where applicable).
6. **Update documentation in the same change** so docs never drift: `CHANGELOG.md` (add entries under `## [Unreleased]`), `CLAUDE.md`, `README.md`, and [docs/DESIGN_AND_REQUIREMENTS.md](docs/DESIGN_AND_REQUIREMENTS.md) when design or requirements change — plus any other affected docs.
7. **Loop lint and tests until green** — run the [Pre-commit checklist](#pre-commit-checklist) (format + lint, then tests with coverage) repeatedly, fixing issues until everything passes and coverage clears the 90% floor.
8. **Open a GitHub PR** with a clear summary and explicit testing notes, linking the issue (e.g. `Closes #<n>`). See [Pull request workflow](#pull-request-workflow).
9. **Wait for CI and loop until it is green** (GitHub Actions). Fix any failure and push again — never hand a red CI back to the user.
10. **Ask the user to merge to `main`.** Do **not** merge yourself unless the user explicitly authorized it for this task (e.g. *"…implement this using the standard procedure and automatically merge to main when done…"*). Without that explicit authorization, stop after CI is green and ask.
11. **Tidy up** (after the change has landed on `main`): remove the worktree (`git worktree remove .worktree/<slug>`) and delete the feature branch both locally and on the remote.
12. **Write a summary to the console** — what changed, the issue and PR links, how it was tested, and anything the user should know.

## Repository status

This is a **starter/template** repository. The only application code today is a
`greet` CLI ([src/barista/greet.py](src/barista/greet.py)); the agentic / WAT /
PydanticAI material below is **forward-looking convention**, not existing code — there
is currently no PydanticAI dependency, no `.agents/`, and no `src/barista/workflows`,
`agents`, or `tools` packages. Treat those sections as the rules to follow *when you
build* such features, not as a description of what exists.

`barista` is a placeholder package name. Rename the whole project with:

```bash
mise run setup-repo -- <new_name>   # renames src/barista/ and rewrites references
```

## Project layout

- Application/business logic: `src/barista/`
- Agentic projects (isolated): `.agents/<subproject>/` — each with its own `pyproject.toml`, `mise.toml`, and `src/` tree
- Tests: `tests/`
- Project metadata and tool config: `pyproject.toml`, `mise.toml`

## Git worktrees

- When asked to work in a git worktree, create it under `.worktree/<worktree-name>` (for example, `.worktree/new-feature-i-m-working-on`).

## Python and tooling

- Python 3.12
- Dependency management via `mise run sync` (uv)
- Use `mise` tasks for all common operations:

| Task | Purpose |
|------|---------|
| `mise run sync` | Install / update dependencies |
| `mise run format` | Auto-format code |
| `mise run lint` | Run linter |
| `mise run test` | Run test suite |
| `mise run coverage` | Run tests with a coverage report |

- Add a unique `mise` task for every new runnable workflow: `mise run workflow-<slug>`

### Common commands

```bash
# First-time setup
mise install && mise run sync && uv run pre-commit install

# Run the CLI
uv run barista-greet          # installed entry point
mise run run                  # equivalent: python -m barista.greet

# Tests
mise run test                                         # full suite
uv run pytest tests/test_greet.py::test_get_version   # a single test
mise run coverage                                     # suite + coverage report
```

**Coverage is a hard gate:** `fail_under = 90` in [pyproject.toml](pyproject.toml), enforced in CI via `coverage-ci`. A drop below 90% fails the build.

> **Enforced gates vs. local hygiene.** The pre-commit hook runs **lint + test**; CI runs **lint + coverage-ci**. Neither gate runs `mise run format`, so formatting is local hygiene you must apply yourself — run it before committing (see Pre-commit checklist), but know that only lint and tests block a commit/merge.

## General principles

- Make minimal, targeted edits; do not disturb unrelated code
- Good code is easy to change; all AI-authored code should stay easy to change as requirements evolve
- Keep public APIs stable unless a change is explicitly requested
- Apply separation of concerns — keep orchestration, reasoning, and side effects distinct (see WAT below)
- Fail loudly: do not swallow errors or hide failures
- Leave touched code clearer or safer than you found it, within the task scope

## Empiricism over speculation

- Treat software development as an empirical discipline: measure, observe, adjust — do not guess and proceed
- When facing a design decision or a performance question, prefer a small focused experiment over a confident assumption
- If you cannot measure whether a change improved things, treat the change as unverified — find a way to make it observable before committing to it
- This applies to agentic work especially: a hypothesis about prompt behavior or tool performance is only valid after evaluation, not before

## Design

### Modularity

- Design every module, class, and tool for high cohesion and low coupling — each unit should do one thing well and depend on as few others as possible
- A component is well-designed if it can be understood, tested, and replaced in isolation without understanding the rest of the system
- Avoid deep dependency chains; if a change in one module ripples unexpectedly through others, treat that as a design problem to fix, not a fact to work around
- Keep modules small enough that their entire purpose is obvious from a brief read

### Abstractions

- Introduce an abstraction only when it removes genuine duplication or hides a complexity that callers should not need to know about
- A leaky or premature abstraction is worse than no abstraction — it adds indirection without reducing complexity
- If an abstraction is hard to name clearly, it is probably the wrong boundary; reconsider the split
- When removing or collapsing an abstraction makes the code clearer, do it — more layers are not inherently better

### Testability as a design signal

- If something is hard to test, that is a design problem, not a testing problem — fix the design
- Hard-to-test code is typically a symptom of tight coupling, hidden state, or mixed concerns; use the difficulty as a diagnostic
- Design modules and tools so their behavior can be verified without running the full system; if you need the whole stack to test one function, the boundaries are wrong

## Code style

- Use type hints throughout: function signatures, public APIs, and meaningful internal variables
- Prefer concrete types; use `Optional`/`Union` explicitly rather than implicitly
- Write Google-style docstrings for every public function, method, and class
- Prefer clarity over cleverness — choose the simplest correct solution
- Comment only when logic is non-obvious; document intent, not mechanics

## Testing

These rules apply to correctness tests (unit, integration, replay). For benchmarking and optimization loops, see the next section.

- Use `pytest` (not `unittest`)
- Tests live in `tests/`; mirror the source tree for unit tests:
  - `tests/agents/` — agent behavior tests with mocked tools/models
  - `tests/tools/` — deterministic tool unit tests
  - `tests/workflows/` — workflow integration and replay tests
- Follow TDD for new functionality:
  1. Write failing tests first
  2. Implement the minimum code to pass
  3. Refactor while keeping tests green
- Keep tests small, focused on behavior, and free of unnecessary duplication
- Cover: expected behavior, edge cases, and regressions
- Every new agentic feature requires:
  - Unit tests for tools and guardrails
  - Integration tests for workflow paths and failure cases
  - At least one determinism/replay test for non-trivial workflows

## Eval-improvement loop (benchmarking and optimization)

When improving code quality, performance, or model behavior, run a structured improvement loop rather than making ad-hoc changes.

**Loop structure**
1. **Baseline** — run the benchmark or eval suite and record the current score/metric
2. **Hypothesize** — identify the most likely lever for improvement based on the results
3. **Change** — make one focused change (prompt, logic, model, config, etc.)
4. **Evaluate** — re-run the benchmark and compare against the previous score
5. **Decide** — continue if there is meaningful improvement; stop if the exit condition is met

**Exit conditions — stop the loop when any of the following is true**
- The target metric or goal has been reached
- The last N consecutive cycles produced improvement below the minimum threshold (default: N=3 cycles, threshold=1%)
- A hard cycle cap is reached (default: 10 cycles) — log a summary and stop rather than running indefinitely

**Rules**
- Make only one change per cycle so causality is clear; do not bundle multiple changes
- Record every cycle: what changed, what the score was before and after, and why the change was made
- If a change makes things worse, revert it before the next cycle
- If the loop exits without reaching the goal, summarize what was tried, what the ceiling appears to be, and what the next logical avenue would be
- Never silently exit the loop — always emit a final summary with the trajectory of scores

## Pre-commit checklist

Work in two loops before committing:

**Loop 1 — formatting and lint (repeat until clean)**
```
mise run format && mise run lint
```
Fix all reported issues, then re-run. Repeat until both pass with no warnings or errors.

**Loop 2 — tests and coverage (repeat until green)**
```
mise run coverage
```
Use `mise run coverage` (not bare `mise run test`) so you verify against the same 90% floor CI enforces — passing tests with coverage below `fail_under = 90` will still fail CI. Fix all failures, then re-run until the suite passes and coverage clears the floor.

Do not move from loop 1 to loop 2 while lint is still failing. Do not commit while any test is failing or coverage is below the floor.

Commit message format: `<type>(<scope>): <concise description of what and why>`

Types: `feat` | `fix` | `chore` | `docs` | `refactor` | `test` | `ci`

Example: `feat(barista): add retry backoff to espresso tool`

## Pull request workflow

This is the PR-specific detail of the [Standard procedure](#standard-procedure-default-implementation-workflow) (steps 8–11); follow that procedure end-to-end for any real unit of work.

- Start from an up-to-date `main` and create a short-lived branch (a worktree branch under `.worktree/` per the standard procedure).
- Make the smallest change that fully solves the task.
- Complete the pre-commit checklist (format, lint, tests + coverage).
- Commit with the required message format.
- Open a PR with a clear summary and explicit testing notes, linking its issue.
- Do not merge until CI is green and any required reviews are complete.
- **Do not merge to `main` yourself unless the user explicitly authorized it** (standard procedure, step 10); otherwise ask the user to merge.
- Once merged, delete the branch locally and remotely and sync `main`.

## Integration and deployability

- Integrate with `main` frequently — at minimum daily, ideally every completed unit of work; keep branches short-lived (a branch older than a day accumulates merge risk).
- `main` must stay releasable at all times: never merge code that breaks the build, fails tests or coverage, or leaves a feature half-wired. Hide incomplete work behind a feature flag rather than keeping a long-running branch.
- If a change is too large to land safely in one go, break it into smaller steps that each leave the system green.
- A broken `main` is the highest-priority fix — nothing else takes precedence until it is green.

## Versioning and Releases

`barista` follows [Semantic Versioning](https://semver.org/) (`MAJOR.MINOR.PATCH`). The
canonical version lives in **one place** — the `version` field of [pyproject.toml](pyproject.toml)
— and the runtime reads it back through `barista.greet.get_version()`. **Never hand-edit the
version string**; always bump it with the release task. Pre-1.0, `MINOR` absorbs breaking
changes and `PATCH` absorbs fixes. See [.agent/VERSIONING.md](.agent/VERSIONING.md) for the
full policy, including how to retire a version with a security bug.

### Cutting a release

1. Land the work on `main` and record it under `## [Unreleased]` in [CHANGELOG.md](CHANGELOG.md)
   (categories: Added / Changed / Deprecated / Removed / Fixed / Security).
2. From an up-to-date, clean `main`, run the release task with the part you are bumping:

   ```bash
   mise run release -- patch     # 0.1.0 -> 0.1.1  (backward-compatible fix)
   mise run release -- minor     # 0.1.0 -> 0.2.0  (backward-compatible feature)
   mise run release -- major     # 0.1.0 -> 1.0.0  (breaking change)
   ```

   The task guards (on `main`, clean tree, synced with `origin/main`, non-empty `[Unreleased]`),
   runs `mise run check`, bumps `pyproject.toml`, rolls the changelog, commits `chore(release): vX.Y.Z`,
   creates an annotated `vX.Y.Z` tag, and pushes with `--follow-tags`.
3. Pushing the tag triggers [.github/workflows/release.yml](.github/workflows/release.yml), which
   verifies the tag matches `pyproject.toml`, re-runs the checks, extracts that version's changelog
   notes, and publishes the GitHub Release (pre-release tags `-alpha`/`-beta`/`-rc` are flagged).

The very first/baseline release is published by tagging the current version directly (the release
task always *bumps*): `git tag -a v0.1.0 -m v0.1.0 && git push --follow-tags`.

### Maintaining `CHANGELOG.md`

[CHANGELOG.md](CHANGELOG.md) follows [Keep a Changelog](https://keepachangelog.com/). Add every
user-facing change under `## [Unreleased]` as it merges — do not wait for release time, and do not
hand-edit already-released sections (the release task owns rolling `[Unreleased]` into a dated
section and maintaining the link references). `mise run changelog-check` fails a release if
`[Unreleased]` is empty, so every release carries notes.

| Task | Purpose |
|------|---------|
| `mise run version` | Print the current version |
| `mise run check` | Pre-release gate: format check, lint, tests + coverage |
| `mise run changelog-check` | Fail if `[Unreleased]` has no entries |
| `mise run release -- {patch\|minor\|major}` | Bump, roll changelog, commit, tag, push |

## Security and data handling

- Never commit secrets or credentials; use environment variables or a secret store
- Avoid logging sensitive data; redact or omit at ingestion boundaries
- Validate all external inputs with Pydantic models before use

## Agentic AI — WAT pattern

All agentic features follow the **WAT** separation strictly:

| Layer | Responsibility |
|-------|---------------|
| **W**orkflow | Orchestration and control flow only — no reasoning, no side effects |
| **A**gent | Reasoning and decision logic only — no direct I/O or tool calls outside the framework |
| **T**ool | Deterministic capabilities and side effects only — no reasoning |

**Prompts must not encode workflow routing, retries, or policy decisions.** Keep orchestration in the workflow layer.

Use **PydanticAI** for agent/model integration and structured outputs by default. If graph orchestration is needed, LangGraph may be used as the workflow engine while preserving WAT separation.

## Agentic AI — folder conventions

```
.agents/
  tools/        # standalone tool implementations and integrations
  workflows/    # standalone workflow orchestration and checkpoints
  agents/       # standalone agent definitions and prompts
  schemas/      # shared Pydantic models across agentic projects
  guardrails/   # safety policies, budgets, and validation
```

Each subdirectory under `.agents/` is an isolated Python project with its own `pyproject.toml`, `mise.toml`, and `src/` tree. Do **not** add agentic dependencies to the main `pyproject.toml`.

## Agentic AI — new workflow checklist

For every new workflow `<workflow_slug>`, create these docs before writing code:

| File | Contents |
|------|---------|
| `docs/workflows/<slug>/specification.md` | Problem statement, stakeholders, SHALL requirements, non-goals, acceptance criteria |
| `docs/workflows/<slug>/plan.md` | Scope, architecture and WAT mapping, milestones, test strategy, rollout |
| `docs/workflows/<slug>/README.md` | Purpose, inputs/outputs, architecture, running, configuration, testing, limitations |

If requirements are unclear, ask before implementing.

When modifying an existing workflow, update only that workflow's scoped docs.

## Agentic AI — determinism, safety, and robustness

**Determinism**
- Use typed Pydantic models for all workflow state
- Make workflow transitions explicit and replayable
- Use stable serialization and hashable checkpoints for replay tests

**Safety**
- Enforce tool allowlists/denylists per environment
- Validate all tool inputs and outputs with Pydantic models
- Add timeouts, retries with bounded counts and exponential backoff

**Robustness**
- Fail closed on policy validation errors
- Treat tools as unreliable boundaries; handle transient failures explicitly
- Provide fallback paths and explicit error states — no silent failures

**Cost efficiency**
- Prefer cheaper models where output quality is acceptable; escalate deliberately
- Cache responses where deterministic and safe
- Track token/cost budgets in workflows and enforce hard caps
