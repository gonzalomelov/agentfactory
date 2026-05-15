# prompts/

This directory contains the public **prompt configurations** that PM-bench compares.

## Contract

A prompt configuration is a **plain-text prompt file** (`.md`) that can be passed via `--prompt <path>` to the PM-bench eval CLI in the private operating repo.

- Files are read as-is — no shell variable expansion
- The eval CLI injects the KR context and OKR structure at call time
- `$variable` references in these files are passed literally to the model

## Files

| File | Purpose |
|------|---------|
| `ideate-issues.md` | Canonical factory ideation prompt — main prompt configuration for cycle-9 dogfood |
| `ideate-issues-prompts.sh` | Bash heredoc variant — sourced by `ideate-issues.sh` in the private operating repo for shell-expansion features (OKR context injection) |

## Usage

```bash
# Once the eval CLI is available:
./scripts/pm-bench-eval.ts \
  --kr <okr-project>#<KR-N> \
  --prompt prompts/ideate-issues.md \
  --output /tmp/eval-output.json
```
