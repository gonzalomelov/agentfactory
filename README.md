# agentfactory

Public substrate for **PM-bench** — a benchmark for product agents.

## Purpose

This repository hosts the **public, inspectable prompt substrate** behind [PM-bench](https://productagents.bygmv.com), the public benchmark that evaluates whether AI product agents can propose product work that moves a real Key Result. It also hosts the **methodology substrate** — the rules, architecture, and documentation that govern how the factory those product agents operate inside actually runs.

> Coding agents can write the code. The harder problem is knowing what to build. PM-bench is a public benchmark that tests whether AI agents can propose product work that moves a real Key Result — not a synthetic task list, not a curated leaderboard, but actual ideation scored against live factory outcomes. Each result page pairs two prompt configurations running the same KR as input and compares their output across four proxy metrics: issue count, AC linter pass rate, token cost, and verification-anchor citation rate. No winner is declared. The numbers are surfaced as-is so builders can reason about the trade-offs themselves.

After the cycle-9 stripdown, this repo is **docs + prompts only**. Runtime infrastructure (agent definitions, workflow scripts, DevContainer, CI, hooks) lives in the private operating repo.

- `prompts/` — canonical ideation prompt files; each is one of the prompt configurations PM-bench compares
- `docs/` — factory methodology: loop architecture, issue conventions, OKR exemplars, scope-split decisions, migration history

## How PM-bench uses this repo

PM-bench evaluates product agents by running an ideation prompt against a real factory Key Result and scoring the candidate issues that the product agent produces. The contract: a prompt configuration is a path to a plain-text `.md` file in `prompts/` that can be passed via the `--prompt` argument to the eval CLI. Every prompt, schema, and scored run is committed in this public substrate so the benchmark is fully reproducible by an outside reader.

See the private operating repo for the issue that created this repo.

## Inside the factory

These documents describe HOW the factory operates (mechanism-first, output-never):

### Methodology docs

| Doc | What it covers |
|-----|---------------|
| [`docs/ISSUE_CONVENTIONS.md`](docs/ISSUE_CONVENTIONS.md) | Issue authoring rules: template, body style, AC quality rules, prerequisites, labels |
| [`docs/FACTORY_LOOP.md`](docs/FACTORY_LOOP.md) | 7-stage autonomous loop (Discover → Prioritize → Develop → Deploy → Distribute → Measure → Iterate) with Mermaid diagram |
| [`docs/OKR_EXEMPLARS.md`](docs/OKR_EXEMPLARS.md) | Few-shot OKR examples: Objective, KR (Track A/B), and work-issue exemplars |
| [`docs/AGENTFACTORY_SPLIT.md`](docs/AGENTFACTORY_SPLIT.md) | Scope-split contract: what lives in this public repo vs the private operating repo |

## Repository Structure

```
agentfactory/
├── prompts/              # Public prompt substrate PM-bench scores product agents against
│   ├── README.md         # Prompt contract (--prompt path convention)
│   ├── ideate-issues.md  # Canonical ideation prompt (one prompt configuration)
│   └── ideate-issues-prompts.sh  # Bash heredoc source (shell-expansion variant)
├── docs/
│   ├── ISSUE_CONVENTIONS.md           # Issue authoring rules
│   ├── FACTORY_LOOP.md                # 7-stage autonomous loop architecture
│   ├── OKR_EXEMPLARS.md               # Few-shot OKR/issue examples
│   └── AGENTFACTORY_SPLIT.md          # Public vs private scope split
├── CLAUDE.md             # Agent instructions for AI coding agents
├── AGENTS.md             # Symlink → CLAUDE.md (same instructions for non-Claude agents)
└── README.md
```
