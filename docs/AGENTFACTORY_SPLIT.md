# Factory Split — Public Substrate vs Private Product

**Decision:** The factory methodology and the public prompt substrate ship from this public repository (`agentfactory`). The revenue product repo is private and contains product code, payment integration, and product-specific configuration.

This document explains the scope boundary and migration discipline.

## Why the Split

Keeping methodology and product code in a single private repo conflates concerns:
- Per-product CI scope
- Cycle-time accounting
- Contributor permissions
- Public inspectability of PM-bench prompt configurations and factory methodology

The split makes the factory's "public, proven product guardrails" claim verifiable: prompt configurations, methodology, and operational scripts are publicly inspectable in this repo.

## What Lives Where

### In `agentfactory` (this repo, public)

After the cycle-9 stripdown, the public substrate is **docs + prompts only**. Runtime infrastructure was removed before the public flip.

| Category | Contents |
|----------|----------|
| Prompts | Ideation prompts (`prompts/`) with substitution placeholders |
| Methodology docs | `docs/ISSUE_CONVENTIONS.md`, `docs/FACTORY_LOOP.md`, `docs/OKR_EXEMPLARS.md`, `docs/AGENTFACTORY_SPLIT.md` |
| Agent instructions | `CLAUDE.md` (with `AGENTS.md` symlink for cross-tool convention) |

### In the private product repo

| Category | Notes |
|----------|-------|
| Revenue product surfaces | All product code (web app, worker, payment integration) |
| ICP agents | Encode product-specific ICP persona research; competitive substrate, permanently private |
| Generic Claude agents | `workflow-planner`, `harsh-pr-reviewer`, `fix-triager`, `visual-verifier` — held privately pending a cycle-10 repo-agnostic refactor |
| Workflow scripts | Tightly coupled to private repo; deferred to cycle-10 repo-agnostic refactor |
| Measure scripts | Tightly coupled to private KR numbers; deferred to cycle-10 |
| Discipline scripts and hooks | AC parsing, test-accompany checks, patch coverage, commit-time hook configuration — deferred to cycle-10 |
| DevContainer and CI workflows | Dev environment and GitHub Actions; deferred to cycle-10 |
| OKR cycle data | `docs/OKR_CYCLES.md` — contains private KR IDs, cycle scores, measurement data |
| Migration manifest | `docs/AGENTFACTORY_MIGRATION_MANIFEST.md` — audit of every artifact; stays private |

## Migration Discipline

Migration is mechanism-first, output-never:
- **Move:** HOW the factory operates (rules, conventions, agent prompts, architecture docs, discipline scripts)
- **Never move:** WHAT it produces (product code, OKR data, customer information, payment integration, KR scores, cycle outcomes)
- **Redact:** anything naming a specific factory product; replace with `<factory-product>` or generic prose
- **Strip:** anything naming specific KR numbers, OKR IDs, or private-repo issue numbers
- **Keep private:** API keys, webhook secrets, deployment project IDs, customer schemas, payment integration code; the migration manifest records this without naming the secret

## Prompt Substitution Contract

Two prompt variants exist with intentionally different substitution strategies:

| Variant | File | Substitution strategy | Consumer |
|---------|------|-----------------------|----------|
| Shell heredoc | Active runtime in product repo | Shell variable injection at call time | Product orchestration scripts |
| Plain-text with placeholder | `agentfactory/prompts/ideate-issues.md` | `{{OKR_CONTEXT}}` placeholder — the eval CLI **must** substitute OKR data before passing to the AI model | PM-bench eval CLI |

**Important:** The `{{OKR_CONTEXT}}` placeholder requires the eval CLI to substitute OKR data before passing the file to the AI. Passing the file unchanged produces non-functional output.

## Out of Scope (deferred)

- Full monorepo migration
- Workflow scripts repo-agnostic refactor
- Measure script template (generic KR measurement pattern)
- Stack-agnostic builder agent
- Deployment-pipeline split
- Secrets migration
- OKR cycle history (contains private scoring data)
