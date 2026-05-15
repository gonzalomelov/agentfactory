# CLAUDE.md

This file provides guidance to AI coding agents working in this repository. `AGENTS.md` is a symlink to this file, so non-Claude agent runtimes pick up the same instructions.

## Overview

**agentfactory** is the public substrate repository behind **PM-bench**, the public benchmark for product agents at [productagents.bygmv.com](https://productagents.bygmv.com). It holds the canonical factory methodology: ideation prompts, issue conventions, workflow architecture docs, and the OKR exemplars that product agents are scored against.

PM-bench evaluates whether a product agent can propose product work that moves a real factory Key Result. This repo is the inspectable input side of that benchmark — every prompt configuration PM-bench compares lives in `prompts/`, and the methodology that frames those configurations lives in `docs/`.

The **operating repo** (private) contains the actual product code, payment integration, and product-specific configuration. That repo imports the methodology from here. See [`docs/AGENTFACTORY_SPLIT.md`](docs/AGENTFACTORY_SPLIT.md) for the full scope split.

## Repository Structure

```
agentfactory/
├── docs/               # Factory methodology docs
├── prompts/            # Ideation prompt files (PM-bench prompt configurations)
├── AGENTS.md → CLAUDE.md   # symlink
├── CLAUDE.md
└── README.md
```

## Rules

- **Mechanism-first / output-never discipline** — this repo holds HOW the factory operates, never WHAT it produces. No product code, OKR data, customer schemas, or payment integration belongs here
- **Published-mirror update protocol** — the active runtime copy of each prompt lives in the private operating repo; changes must be made there first, then mirrored here. Do not edit the public copy and expect it to propagate upstream
- **No vendor names in scripts** — scripts must be generic and reusable. Replace any specific product, service, or vendor name with a placeholder or generic prose before committing
- **Redact before publishing** — anything naming a specific factory product must be replaced with `<factory-product>` or generic prose. Strip specific KR numbers, OKR IDs, and private-repo issue numbers

## Prompt Authoring Workflow

The **active runtime copy** of each prompt lives in the private operating repo. Edit order:

1. Edit the shell prompt file in the private operating repo (active runtime)
2. Mirror changes to the corresponding file in `prompts/` here (published mirror)
3. If the structural prompt text applies to the plain-text `.md` variant, update `prompts/ideate-issues.md` accordingly

A nightly sync check diffs the local runtime copy against this mirror and fails if they diverge. The mirrored prompt files are the prompt configurations PM-bench reads when it scores a product agent.

See [`docs/AGENTFACTORY_SPLIT.md`](docs/AGENTFACTORY_SPLIT.md) for the full prompt substitution contract and substitution strategy per variant.

## Migration Discipline

Migration is mechanism-first, output-never:

- **Move:** HOW the factory operates (rules, conventions, agent prompts, architecture docs)
- **Never move:** WHAT it produces (product code, OKR data, customer information, payment integration, KR scores, cycle outcomes)
- **Redact:** anything naming a specific factory product; replace with `<factory-product>` or generic prose
- **Strip:** anything naming specific KR numbers, OKR IDs, or private-repo issue numbers
- **Keep private:** API keys, webhook secrets, deployment project IDs, customer schemas, payment integration code

See [`docs/AGENTFACTORY_SPLIT.md`](docs/AGENTFACTORY_SPLIT.md) for the canonical migration discipline and the artifact manifest.

## What Lives Where

| Bucket | Contents |
|--------|----------|
| **This repo (public substrate)** | Ideation prompts, issue conventions, factory loop docs, generic agents, workflow diagrams and pseudocode, OKR exemplars, discipline scripts, DevContainer config, CI workflows |
| **Private operating repo** | Product code, active runtime scripts, payment integration, ICP agents, product-specific config, measure scripts, deployment pipeline, secrets |

Artifacts that are deferred to a future migration cycle remain in the private operating repo until the cycle-10+ refactor ships. See [`docs/AGENTFACTORY_SPLIT.md`](docs/AGENTFACTORY_SPLIT.md) for the full table and deferral rationale.

## Out of Scope

Deferred to cycle-10 and beyond:

- Full monorepo migration
- Workflow scripts repo-agnostic refactor
- Measure script template for generic KR measurement
- Stack-agnostic builder agent
- Worker migration
- Deployment-pipeline split
- Secrets migration
- CI/CD parity build
