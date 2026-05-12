# BASED Agent Framework

A spec-oriented agent framework for bootstrapping agent-driven software projects.

This repository provides a predefined agent workflow, project structure, and operating rules for building software through a controlled development cycle:

```text
task -> spec -> implementation
```

The goal is to make agent development predictable, auditable, and scoped. Agents should not perform unspecified work. Every implementation must come from an approved spec.

---

## Purpose

This repository is intended to be used as a starter project for new agent-based development workflows.

When starting a new project, copy or extend this repository to get:

- A predefined agent workflow
- A spec-first development process
- Separation of responsibilities between agents
- A persistent `specs/` directory for project context
- Versioned spec documents per feature
- Guardrails against unspecific or out-of-scope work

---

## Development Cycle

All work follows this lifecycle:

```text
Task -> Spec -> Implementation
```

### 1. Task

A task is the initial user request, idea, feature request, bug report, or change request.

Tasks may be rough or incomplete.

The task is not implemented directly.

Instead, it is passed to the Spec Architect Agent.

---

### 2. Spec

The Spec Architect Agent converts the task into a clear, actionable specification.

The spec should define:

- Goal
- Background/context
- Functional requirements
- Non-functional requirements
- Constraints
- Non-goals
- Acceptance criteria
- Risks or open questions
- Expected files, modules, or systems affected
- Verification requirements

No implementation should begin until the spec is clear enough to execute.

---

### 3. Implementation

The Orchestrator Agent is responsible for turning an approved spec into implementation work.

The orchestrator:

- Reads the spec
- Breaks it into bounded work units
- Delegates work to suitable implementation agents
- Reviews results against the spec
- Requests fixes when needed
- Reports final status

The orchestrator must not invent requirements or perform work outside the spec.

---

## Agent Responsibilities

### Spec Architect Agent

Responsible for:

```text
task -> spec
```

The Spec Architect Agent transforms user intent into a concrete specification.

It should clarify ambiguity, identify missing requirements, and produce a versioned spec document inside `specs/<feature-id>/`.

The Spec Architect Agent does not implement code.

---

### Orchestrator Agent

Responsible for:

```text
spec -> implementation
```

The Orchestrator Agent executes only from an existing spec, plan, checklist, ticket, or implementation brief.

It delegates implementation work to suitable agents and verifies that the result satisfies the spec.

The Orchestrator Agent must refuse to proceed if no actionable spec is provided.

---

## Specs Directory

All feature context lives inside the `specs/` directory.

Each feature or change gets its own directory:

```text
specs/<feature-id>/
```

Example:

```text
specs/user-authentication/
  001-initial-spec.md
  002-add-password-reset.md
  003-change-session-handling.md
```

Each file should describe a specific version, change, or refinement of the spec.

Specs are part of the project history and should be committed with the code they describe.

---

## Spec Versioning

Specs should be append-only when possible.

Instead of rewriting history, create a new spec version when requirements change.

Recommended naming pattern:

```text
001-initial-spec.md
002-update-<short-description>.md
003-change-<short-description>.md
```

Example:

```text
specs/payment-flow/
  001-initial-spec.md
  002-add-refund-support.md
  003-update-error-handling.md
```

Each new spec version should explain:

- What changed
- Why it changed
- Which previous assumptions are replaced
- New acceptance criteria
- Impact on implementation

---

## Project Rules

1. No implementation without a spec.
2. No work outside the approved spec.
3. Every feature keeps its context in `specs/<feature-id>/`.
4. Spec changes are recorded as new files.
5. Agents must respect their role boundaries.
6. The Spec Architect creates or updates specs.
7. The Orchestrator implements only from specs.
8. Acceptance criteria must be checked before work is considered complete.

---

## Recommended Repository Structure

```text
.
├── agents/
│   ├── ARCHITECT.md
│   └── ORCESTRATOR.md
├── specs/
│   └── <feature-id>/
│       ├── 001-initial-spec.md
│       └── 002-update-description.md
└── README.md
```

---

## Workflow Example

### Step 1: User provides task

```text
Add user login with email and password.
```

### Step 2: Spec Architect creates spec

```text
specs/user-login/001-initial-spec.md
```

The spec defines requirements, constraints, acceptance criteria, and verification steps.

### Step 3: Orchestrator reads spec

The Orchestrator Agent breaks the spec into implementation tasks and delegates them to suitable agents.

### Step 4: Implementation is verified

The final result is checked against the spec acceptance criteria.

If requirements change later, create another spec file:

```text
specs/user-login/002-add-password-reset.md
```

---

## Core Principle

This repository is designed around controlled agent development.

Agents should not guess, overreach, or perform unrelated work.

Every meaningful change should be traceable back to a spec.
