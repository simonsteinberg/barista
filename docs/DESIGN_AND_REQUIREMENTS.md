# Design and Requirements

This document is the authoritative description of **what** the Barista system does and
**why**. It captures requirements, architecture, and the significant decisions behind
them. It is paired with [CLAUDE.md](../CLAUDE.md) (the operational checklist) and
[.agent/SOFTWARE_ENGINEERING.md](../.agent/SOFTWARE_ENGINEERING.md) (the engineering
reasoning).

> **Maintenance:** Keep this document current. Any session that changes design or
> requirements — new/altered requirements, a different architecture or component
> boundary, a changed data model, or a non-trivial trade-off — must update the
> relevant section here in the same change. Record dated entries in the Decision Log.

---

## 1. Purpose and scope

- **Problem statement:** _What problem does Barista solve, and for whom?_ <!-- TODO -->
- **In scope:** _What this system is responsible for._ <!-- TODO -->
- **Out of scope / non-goals:** _What it deliberately does not do._ <!-- TODO -->

## 2. Stakeholders and users

- _Who uses or depends on the system, and what they need from it._ <!-- TODO -->

## 3. Requirements

Use SHALL/SHOULD language. Give each requirement a stable ID so decisions and tests
can reference it.

### 3.1 Functional requirements

| ID | Requirement | Priority | Notes |
|----|-------------|----------|-------|
| FR-1 | _The system SHALL …_ | Must | <!-- TODO --> |

### 3.2 Non-functional requirements

| ID | Requirement | Notes |
|----|-------------|-------|
| NFR-1 | _Performance / reliability / cost / security target …_ | <!-- TODO --> |

### 3.3 Constraints and assumptions

- _Technical, regulatory, or business constraints; assumptions being relied on._ <!-- TODO -->

## 4. Architecture

- **Overview:** _High-level shape of the system and how the pieces fit together._ <!-- TODO -->
- **Components and boundaries:** _Each major module/service, its single responsibility,
  and its dependencies (high cohesion, low coupling)._ <!-- TODO -->
- **WAT mapping (agentic features):** _Which parts are Workflow (orchestration), Agent
  (reasoning), and Tool (side effects). See CLAUDE.md._ <!-- TODO -->
- **Axes of expected change:** _Where the design is built to flex (e.g. pluggable
  rules, new component types) so those changes stay cheap._ <!-- TODO -->

## 5. Data model

- _Key entities, their typed (Pydantic) models, and where validation happens at the
  boundary._ <!-- TODO -->

## 6. Acceptance criteria

- _Observable conditions that mean a requirement is met; link back to requirement IDs.
  These should be expressible as tests._ <!-- TODO -->

## 7. Decision log

Append-only. Newest first. Record non-trivial trade-offs so the reasoning survives.

| Date | Decision | Alternatives considered | Rationale |
|------|----------|------------------------|-----------|
| 2026-06-03 | Established this document as the authoritative design & requirements record. | Keep design implicit in code/PRs. | Prevents drift between intent and implementation; gives sessions a single place to update. |
