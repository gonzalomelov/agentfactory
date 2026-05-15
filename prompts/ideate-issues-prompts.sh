#!/usr/bin/env bash
# Prompt functions for ideate-issues.sh
# Each function outputs a plain-text prompt via heredoc.
# Variables expand at call time (shell variant — see ideate-issues.md for static variant).
#
# Sync pair — edit active runtime first, then mirror to published copy:
#   Active runtime: scripts/workflow/ideate-issues-prompts.sh  (private operating repo)
#   Published mirror: prompts/ideate-issues-prompts.sh  (agentfactory)
# See docs/AGENTFACTORY_SPLIT.md for authoring workflow.

# --- Ideation prompt ---
# Given Objective context and KR measurement, ideate 3-4 issues/experiments/initiatives.
# No existing issues shown — unbiased ideation.
_ideate_prompt() {
  local okr_context="$1"
  local issue_template="$2"
  local exemplars="${3:-}"
  cat <<'EOF'
You are a product-minded engineer working on <factory-product>.

Your task: read the Objectives and Key Results below, then ideate 3-4 concrete issues/experiments/initiatives for EACH active Key Result that would move the needle toward achieving it.

## OKR Context

EOF
  echo "$okr_context"
  cat <<'EOF'

## Agent Capabilities

All tasks will be executed by autonomous coding agents running inside a DevContainer. They have access to:

**CLIs:**
- `gh` CLI for GitHub operations (full access)
- `<hosting>` CLI for hosting-platform operations (read ops, redeploy, env vars — NOT deploys)
- `claude` CLI for AI reasoning
- Shell access for any CLI tool

**MCP servers (API access, no browser needed):**
- `<analytics-provider>` — analytics, feature flags, experiments, error tracking
- `<payment-provider>` — payment operations (sandbox and production)
- `<error-tracker>` — error tracking and performance monitoring
- `<email-mcp>` — read, search, draft emails
- `<calendar-mcp>` — events, scheduling

**Testing:**
- Playwright test runner (`npx playwright test` from `apps/web`) — headless, for testing the app itself (localhost/staging). No auth states, no interactive sessions, no third-party dashboard access.

**What agents CANNOT do (requires human via host playwright-cli):**
- Interactive browser sessions with third-party services (search console, <payment-provider> dashboard, social platforms)
- Headed browser mode with pre-authenticated sessions
- Any task requiring login to an external website

Do NOT self-censor proposals as "human-only." Frame every proposal as agent-executable. If a task requires human/host-level browser interaction (logging into external dashboards, submitting forms on third-party sites), list those as prerequisites.

## Issue Template (from .github/ISSUE_TEMPLATE/bug.yml)

Issues MUST follow the repository's issue template structure below. Read the field labels, descriptions, and placeholders to understand what each section expects.

```yaml
EOF
  echo "$issue_template"
  cat <<'EOF'
```

## Issue Creation Conventions

### Summary — What & Why
- Describe the PROBLEM and MOTIVATION, not the solution
- DO NOT include implementation details like specific function names, file paths, event names, page routes, or technical approaches
- The implementing agent will read the codebase and decide HOW to solve it
- End with the CONSEQUENCE of inaction, not the solution direction
- Bad: "Create a static page at /personalized-invitations with keyword-rich H1 and FAQ schema markup"
- Good: "<factory-product> has no content pages targeting search queries. Users searching for personalized invitations won't find us because there's nothing for Google to index beyond the app shell."
- Bad ending: "The overlay checkout flow needs to redirect back to <factory-overlay-product>" (prescribes solution)
- Good ending: "Without this fix, paying customers land on the wrong domain and may never see their download" (states consequence)

### Acceptance Criteria (pre-merge)
- Must describe **observable outcomes**, not implementation details or internal process artifacts
- The implementing agent decides the technical approach — ACs verify the RESULT, not the METHOD
- ACs describe what a user or system can observe after the work is done, not internal steps like "file stored in repo" or "documentation updated in comments"
- Bad: "JSON-LD FAQPage schema markup present" (prescribes implementation)
- Good: "Search engines can extract FAQ content from the page" (verifiable outcome)
- Bad: "Open Graph metadata (title, description, image) set" (prescribes implementation)
- Good: "Social sharing preview shows correct title, description, and image" (verifiable outcome)
- Bad: "Submission copy stored in the repo" (process artifact)
- Good: "Each target directory has a submission-ready description and screenshot" (outcome)
- No generic boilerplate (tests passing, lint clean, nightly passes). The implementing agent decides quality gates.

### Acceptance Criteria (post-merge)
- Verified after merge and deployment by the **nightly workflow** (automated Playwright tests against production)
- The nightly CAN: load pages, check HTTP status, verify page content, run smoke tests, check analytics events, validate sitemaps
- The nightly CANNOT: complete real purchases, interact with third-party dashboards, trigger external webhooks, verify visual designs
- If the nightly workflow cannot fully verify it without human involvement, do NOT include it. Leave ac_post_merge as an empty array. It is BETTER to have zero post-merge ACs than aspirational ones that can never be automated.
- **ACs must be verifiable at merge time.** Never write ACs that depend on a future calendar date (e.g., "at cycle wrap, post X"). Cycle-level measurement activities belong to the KR's measure script (`--snapshot` flag), not to work issue ACs. If an AC cannot be checked off within hours of merging, it does not belong here.
- When you DO include post-merge ACs, write them as **step-by-step verification instructions**: (1) what tool or endpoint to use, (2) what to check, (3) what the expected result is. The nightly workflow will turn these into automated Playwright tests.

Here is a real example of high-quality post-merge ACs:

```
- [ ] Clicking a quick-start theme card in production serves a pre-generated image without triggering an image generation API call. Verify by:
  1. Open production with Playwright CLI, click a theme card (e.g., dinosaur) to trigger the flow
  2. Load the `<hosting>` auth state and navigate to the `<hosting>` runtime logs dashboard
  3. Search/filter logs for "Serving pre-generated image for example theme:" — this console.log fires server-side when the cache is hit
  4. Confirm the log entry appears (cache hit) and no image generation error or timeout occurred
```

Notice: specific steps, specific tools, specific expected results. This is the quality bar.

- Bad: "<factory-overlay-product> loads and displays pricing information"
- Good: "Load <factory-overlay-product> with Playwright. Verify HTTP 200. Verify page contains text matching a pack price (e.g., '$X.XX'). Verify at least one CTA button is visible."
- Bad: "<analytics-provider> shows overlay-specific events when a user completes the overlay flow on production" (nightly cannot trigger a real user flow — do NOT include this)

### Prerequisites for Autonomous Execution
- Human setup required before an agent can run this end-to-end
- ALL items must be checked before the issue moves to Todo
- Leave empty if the agent can execute fully autonomously
EOF
  if [[ -n "$exemplars" ]]; then
    cat <<'EOF'

## Few-Shot Exemplars

Below are concrete examples of well-formed Objectives, KRs, and work issues from a prior cycle that passed pipeline-health. Use these as shape reference for formatting and outcome-orientation. Do NOT copy content; only imitate the structure.

EOF
    printf '%s\n' "$exemplars"
    echo ""
  fi
  cat <<'EOF'

## Instructions

For each active KR:
1. Read the Objective's "Why" and "What success looks like" to understand strategic intent
2. Read the KR's measurement criteria to understand exactly what counts as progress
3. Propose 3-4 concrete, actionable issues/experiments/initiatives that would directly contribute to achieving the KR
4. Include a mix of safe bets and creative experiments where appropriate
5. Each proposal should be small enough for a single PR (effort S or M, not L)

## Output Format

Respond with ONLY valid JSON, no markdown fences, no explanation. The schema:

{
  "kr_issues": [
    {
      "kr_number": 28,
      "kr_title": "KR title here",
      "proposals": [
        {
          "title": "Short imperative title (like a GitHub issue title)",
          "summary": "3-5 line description: what and why, not how",
          "ac_pre_merge": ["Outcome-based AC item 1", "Outcome-based AC item 2"],
          "ac_post_merge": ["Post-deploy verification item (only if nightly can verify it)"],
          "prerequisites": ["Human setup item 1", "Human setup item 2"],
          "priority": "P0|P1|P2|P3",
          "effort": "S|M",
          "work": "Agent|Human",
          "labels": ["enhancement|bug|experiment|content|seo|infrastructure"]
        }
      ]
    }
  ]
}

Priority guidance: P0 = blocks the KR entirely, P1 = high impact on KR, P2 = moderate, P3 = nice to have.
Prerequisites: leave as empty array [] if the agent can execute fully autonomously.
work: "Agent" if an autonomous coding agent can execute end-to-end, "Human" if it requires human interaction (e.g., third-party dashboards, manual browser sessions).
ac_post_merge: leave as empty array [] if nothing can be automatically verified by the nightly.
EOF
}

# --- Dedup prompt ---
# Given ideated proposals and existing Solo project issues, find overlaps.
_dedup_prompt() {
  local proposals_json="$1"
  local existing_issues="$2"
  local issue_template="$3"
  cat <<'EOF'
You are deduplicating proposed issues against existing ones in a GitHub project.

## Proposed Issues (from ideation)

EOF
  echo "$proposals_json"
  cat <<'EOF'

## Existing Issues in Solo Project

EOF
  echo "$existing_issues"
  cat <<'EOF'

## Instructions

For each proposed issue, determine if it overlaps with an existing issue:
- "match" — An existing issue covers this proposal well enough. Link it instead of creating a new one.
- "partial" — An existing issue is related but its scope or description needs updating to also cover this proposal. Update then link.
- "novel" — No existing issue covers this. Create a new one.

Be conservative with "match" — only use it when the existing issue truly covers the same work. Different approaches to the same goal are NOT matches.

## Issue Template (from .github/ISSUE_TEMPLATE/bug.yml)

The body for novel and partial issues MUST follow the repository's issue template structure. Read the field labels, descriptions, and placeholders to understand what each section expects.

```yaml
EOF
  echo "$issue_template"
  cat <<'EOF'
```

## Issue Creation Conventions

- Summary: describe the **problem and motivation** (why and what), not the solution (how). End with the consequence of inaction, not the solution direction.
- Pre-merge ACs: **observable outcomes**, not implementation details or process artifacts. No generic boilerplate.
- Post-merge ACs: **step-by-step verification instructions** the nightly can automate (what tool, what to check, expected result). If the nightly cannot verify it without human involvement, leave empty. Better zero than aspirational.
- Prerequisites: human setup needed before agent can run. Empty if fully autonomous.

## Output Format

Respond with ONLY valid JSON, no markdown fences, no explanation. The schema:

{
  "results": [
    {
      "kr_number": 28,
      "proposal_title": "The proposed issue title",
      "action": "match|partial|novel",
      "existing_issue_number": 123,
      "update_title": "Updated title (only for partial)",
      "update_body": "Updated body in markdown following the issue template (only for partial)",
      "title": "Issue title (for novel, or original for match)",
      "body": "Full issue body in markdown following the issue template (for novel)",
      "priority": "P0|P1|P2|P3",
      "effort": "S|M",
      "work": "Agent|Human",
      "labels": ["enhancement"]
    }
  ]
}

For "match": set existing_issue_number, title (from existing), and null for update/body fields.
For "partial": set existing_issue_number, update_title, update_body, work.
For "novel": set title, body, priority, effort, labels. existing_issue_number is null.
EOF
}

# --- Ideation review prompt ---
# CEO-level review of proposed issues against KR metrics.
# Run on synthesis files BEFORE creating issues.
# Traces causal chains, flags weak links, keeps it concise.
_ideation_review_prompt() {
  local end_date="$1"
  cat <<EOF
You are the CEO reviewing this week's sprint plan. The company ships or dies based on
hitting these KR metrics by $end_date. Be rigorous.

Your job is to evaluate whether the proposed ISSUES are the right ones to move each KR metric.
Do NOT comment on execution timing, Human availability, or when things should start.
Focus only on: are these the right initiatives?

For each KR, trace the causal chain: issues ship -> ... -> KR metric moves.

For each issue, rate the causal link:
- Strong: shipping this directly changes the KR number
- Weak: helps but does not guarantee the KR moves
- None: no connection to the KR metric

For each KR, give a verdict:
- READY: the issues will move the metric when shipped
- WEAK: issues exist but the causal chain has a gap (explain the broken link)
- BROKEN: no issue has a Strong causal link to the KR

Output a table with one row per KR and one row per issue under it:
- KR rows: columns are KR, Causal Chain (full chain from issues to metric), Verdict (READY/WEAK/BROKEN)
- Issue rows (indented under their KR): columns are Issue, Causal Chain (how this issue connects), Causal Link (Strong/Weak/None)
- For WEAK/BROKEN KRs, add a Fix row with the minimum missing issue (title, effort, work type)

Keep it concise. No prose between rows.
EOF
}
