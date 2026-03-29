# Barista Agent Instructions

## Project layout
- Python package source lives under src/barista.
- Tests live under tests.
- Main project metadata and tool config are in pyproject.toml and mise.toml.

## Python and tooling
- Use Python 3.12 for local commands.
- Use mise tasks where possible.
- Useful tasks:
  - mise run test
  - mise run lint
- Use type hints for Python code (function signatures, public APIs, and meaningful internal variables where useful).
- Keep typing precise and readable; prefer concrete types and clear Optional/Union usage when needed.

## Testing rules
- Use pytest, not unittest, for new and updated tests.
- Add or update tests in tests/ when changing behavior.
- Keep tests small, readable, and focused on behavior.
- For new functionality, follow Test-Driven Development (TDD):
  - Write failing tests first.
  - Implement the minimal code needed to pass.
  - Refactor while keeping tests green.
- Aim for comprehensive and concise tests that cover expected behavior, edge cases, and regressions without unnecessary duplication.

## Quality checks before commit
- Run lint checks before committing changes.
- Run the relevant tests before committing changes.
- If changing behavior, ensure tests cover the change.
- Do not finish work until linting and all relevant tests pass successfully.

## Practical expectations
- Prefer minimal, targeted edits.
- Do not revert unrelated local changes.
- Keep public APIs stable unless a change is explicitly requested.

## Agentic workflow template rules
- This repository is a template for production-grade agentic workflows.
- When the user asks to generate or modify agentic workflows, default to Python + PydanticAI.
- For repositories with multiple workflows, scope docs per workflow to avoid file collisions.
- For every new workflow `<workflow_slug>`, start by writing requirements in `docs/workflows/<workflow_slug>/specification.md` using SHALL language.
- After requirements, write an implementation plan in `docs/workflows/<workflow_slug>/plan.md`.
- If requirements are unclear, ask the user before implementing.
- Add a comprehensive README for each workflow at `docs/workflows/<workflow_slug>/README.md`.
- Add a unique `mise` task for each new runnable workflow (for example `workflow-<workflow_slug>`).
- When modifying an existing workflow, update only that workflow's scoped docs.
- Use canonical workflow docs structure under `docs/workflows/<workflow_slug>/`:
  - `specification.md`: Problem Statement, Stakeholders, Requirements (SHALL), Non-Goals, Acceptance Criteria.
  - `plan.md`: Scope, Architecture and WAT Mapping, Milestones, Test Strategy, Rollout and Validation.
  - `README.md`: Purpose, Inputs and Outputs, Architecture, Running, Configuration, Testing, Limitations.
- Follow the WAT pattern strictly:
  - Workflows: orchestration and control flow only.
  - Agents: reasoning and decision logic only.
  - Tools: deterministic capabilities and side effects only.
- Keep orchestration outside prompts. Prompts should not encode workflow routing, retries, or policy decisions.

## Architecture and folder conventions for agentic workflows
- Use this structure for new workflow features:
  - src/barista/workflows/ -> workflow orchestration, state transitions, routing, retries, and checkpoints.
  - src/barista/agents/ -> agent definitions, system prompts, and reasoning policies.
  - src/barista/tools/ -> tool implementations, tool schemas, and external integrations.
  - src/barista/schemas/ -> Pydantic request/response/state models.
  - src/barista/guardrails/ -> safety policies, budget limits, timeout rules, and validation.
  - tests/workflows/ -> workflow integration and replay tests.
  - tests/agents/ -> agent behavior tests with mocked tools/models.
  - tests/tools/ -> deterministic tool unit tests.

## Determinism, safety, and robustness requirements
- Determinism:
  - Use typed state models (Pydantic) for workflow state.
  - Make workflow transitions explicit and replayable.
  - Prefer stable serialization and hashable checkpoints for replay tests.
- Safety:
  - Enforce tool allowlists/denylists per environment.
  - Validate all tool inputs and outputs with Pydantic models.
  - Add timeouts, retries with backoff, and bounded retry counts.
- Robustness and failure tolerance:
  - Fail closed on policy validation errors.
  - Treat tools as unreliable boundaries; handle transient failures explicitly.
  - Add fallback paths and error states instead of silent failures.
- Cost efficiency:
  - Use model selection policies (cheap model first when acceptable).
  - Add response caching where deterministic and safe.
  - Track token/cost budgets in workflows and enforce hard caps.

## Implementation defaults
- Use PydanticAI for agent/model integration and structured outputs.
- Keep workflows framework-agnostic; if graph orchestration is needed, LangGraph can be used as the workflow engine while preserving WAT separation.
- New agentic features must include:
  - Unit tests for tools and guardrails.
  - Integration tests for workflow paths and failure cases.
  - At least one determinism/replay test for non-trivial workflows.
