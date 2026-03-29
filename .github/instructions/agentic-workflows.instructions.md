---
applyTo: "src/barista/**/*.py,tests/**/*.py"
description: "Use when creating or modifying agentic workflows, agents, tools, guardrails, or workflow schemas. Enforces PydanticAI + WAT architecture with determinism, safety, robustness, and cost controls."
---

# Agentic Workflow Generation Rules

## Stack defaults
- Default to Python + PydanticAI for agentic workflow implementation.
- Keep model provider usage behind typed interfaces to avoid lock-in.
- Prefer deterministic execution paths over purely conversational loops.

## WAT separation (required)
- Workflows layer (`src/barista/workflows/`): orchestration only (routing, retries, checkpoints, state transitions).
- Agents layer (`src/barista/agents/`): reasoning and planning only.
- Tools layer (`src/barista/tools/`): deterministic side effects and external integrations.
- Do not mix orchestration logic into prompts or tools.

## Required structure for new features
- `src/barista/workflows/`
- `src/barista/agents/`
- `src/barista/tools/`
- `src/barista/schemas/`
- `src/barista/guardrails/`
- `tests/workflows/`
- `tests/agents/`
- `tests/tools/`

## Determinism requirements
- Use typed workflow state models (Pydantic).
- Make transitions explicit, replayable, and testable.
- Use stable serialization for checkpoints and event logs.
- Add at least one replay test for non-trivial workflows.

## Safety, robustness, and failure tolerance requirements
- Validate all tool inputs/outputs using Pydantic schemas.
- Enforce environment-specific tool policies (allowlist/denylist).
- Add timeout bounds and bounded retries with backoff for tool calls.
- Fail closed on policy or validation errors.
- Add explicit fallback/error branches instead of silent failure.

## Cost efficiency requirements
- Track token/cost budget in workflow state.
- Enforce hard budget caps.
- Prefer cheap models for low-risk steps and escalate only when needed.
- Cache deterministic model/tool results when safe.

## Testing requirements
- Add unit tests for tools and guardrails.
- Add integration tests for workflow paths and failure paths.
- Keep tests focused, deterministic, and readable.
