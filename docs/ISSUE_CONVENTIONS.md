# Issue Creation Conventions

Single source of truth for how issues are written in this factory. All other locations (root `CLAUDE.md`, workflow docs, the `/issue-create` skill, auto-memory) should link here instead of duplicating these rules.

## 1. Tooling

- Always create issues via the `/issue-create` skill. The skill reads this file and then calls `gh issue create`
- Never hand-roll `gh issue create` ad hoc; that is how headings drift
- Never use the `updateProjectV2Field` GraphQL mutation to change GitHub Project fields; use the GitHub UI or `gh project item-edit` CLI

## 2. Template

Issues follow `.github/ISSUE_TEMPLATE/bug.yml`. Required sections, in order, with these exact H3 headings (the `issue-lint` workflow enforces the strings):

```markdown
### Summary — What & Why
### Acceptance Criteria (pre-merge)
### Acceptance Criteria (post-merge)
### Prerequisites for Autonomous Execution
```

Optional sections from the template: `### Config & Dependencies`, `### Error & Edge-Case Behavior`, `### Testing & Workflow`, `### Scope/Notes`.

## 3. Body style

Issue bodies describe **what and why**, never **how**. Implementation details (chosen library, specific files, code snippets, exact env var gating) belong in the plan comment or the PR, not the issue body. Reviewers and agents should be able to propose a different implementation without the issue needing a rewrite. For AC-specific rules on WHAT vs HOW, see the subsection in Section 4 below.

Writing rules:

- English only. Do not mix languages even when quoting foreign-language sources; translate inline
- No em dashes in agent-written prose. Use commas, semicolons, or rewrite. The template-mandated `### Summary — What & Why` heading is exempt (the `issue-lint` bot requires it)
- **Issue body is the source of truth** for scope and context. Issue comments are runtime notes (status updates, baseline outputs, verification evidence); they are not part of the work description and must not be used to expand or redefine scope. Any material scope change must update the body itself, not hide in a comment. Agents reading only the body should get the full picture

## 4. Acceptance Criteria

Two checklists. Both are mandatory sections, but either can be empty when genuinely not applicable (explain why in `### Scope/Notes`).

**Pre-merge ACs** are verified before merge on the feature branch by the autonomous workflow:

- Every AC must be specific and verifiable. No boilerplate like "tests passing" or "works as described"
- Every AC must be checkable within hours of merging. If an AC cannot be confirmed that quickly, it does not belong on a work issue
- Cycle-level measurement ("post evidence at cycle wrap", "record result at cycle close") belongs to the KR's measure script (`--snapshot`), not to work issue ACs
- ACs that require deployment (staging or production CI, live URLs) belong in post-merge

**Post-merge ACs** are verified after merge and deployment by the nightly workflow:

- Check live URLs, analytics events, error-tracking tags, production analytics, anything that only exists after deploy
- Each AC must still be a single pass/fail check, not a measurement ritual
- Never trigger a workflow as part of a post-merge AC. The nightly verifier runs on the single-slot self-hosted runner, so firing a new workflow from inside the verifier job creates a queue deadlock that only breaks at the step timeout. This applies to the direct form (`gh workflow run <name>`) AND to indirect workflow triggers via side-channel events: issue or PR body edits, comments, label changes, pushes to a branch, opening a PR. Any of those side-channel actions can fire an `on:` matcher for another workflow assigned to the same self-hosted runner and reproduce the deadlock. Phrase post-merge ACs as observation of pre-existing runs: query `gh run list --workflow=<name> --limit N --json ...` for runs already produced by ordinary product traffic or by the merge that closed the issue, then assert on their conclusion or logs. Do not author ACs that require the verifier to produce the run it then inspects.

**Time-gated behavior must constrain both sides of the gate.** When an AC describes logic that fires at or after a specific date or deadline, write separate pre-gate and post-gate expectations. A single "when the gate fires, produce X" line is not enough: a premature-firing gate produces the same X output and slips past review. Review agents only have the AC text to judge against; if the text does not forbid pre-gate firing, they will accept it. Example shape: "Running the script before `<deadline>` produces non-gated output" + "Running the script after `<deadline>` with the triggering condition met produces gated output."

**ACs constrain WHAT and WHY, never HOW.** Every AC must describe an observable outcome (run a command, hit an endpoint, check a visible result), not an implementation step. File-scope ACs (e.g., "edit file X to add Y") trap agents into satisfying the literal text while the system still does not work. Functional ACs let the agent choose any implementation path and verify the outcome end-to-end.

Bad (HOW-style, file-scope):

> - [ ] Edit `apps/web/middleware.ts` to add a rewrite rule for `/api/chat` on the `pm-agent` host

Good (functional, observable):

> - [ ] Running `curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -d '{"messages":[{"role":"user","content":"hello"}]}' https://example.com/api/endpoint` returns HTTP `200` with a `Content-Type: application/json` response header

Rationale: HOW-style ACs let code pass review while the system remains broken; only functional checks catch the real failure.

**Prescriptive-file-scope anti-pattern.** A recurring variant of the HOW-style failure is an AC that names a specific file and a change to make inside it (e.g., "add rule X to `middleware.ts`"). This is a prescriptive-file-scope AC: it conflates the implementation step with the acceptance criterion. Agents passing a file-scope AC have only satisfied the literal text; they have not demonstrated that the system works. Rewrite every prescriptive-file-scope AC as a functional check: run a command, observe an output, hit an endpoint.

**ACs must state a single observation, not branch on environment.** Bad ACs bundle conditional or fallback logic ("if X reachable do A, else B"; "drawing on (a) X AND (b) Y" where Y silently substitutes when X is out of reach) into the AC body. The agent's execution environment may not satisfy the precondition, leaving the AC under-specified: the agent passes the literal text by satisfying the cheaper branch while the substantive observation goes unverified. State one path-of-record observation. If multiple sources are genuinely acceptable, name the positive shape ("≥3 citations, each a public URL or a repo-relative path") rather than ranking sources by reachability.

Bad (conditional fallback):

> - [ ] Comment cites ≥3 recent developments, drawing on (a) the local archive at `/path/to/research/` AND (b) web search for items newer than the archive's latest date

Good (single observation):

> - [ ] Comment cites ≥3 recent developments, each citation a public URL or a repo-relative path the reviewer can open

**ACs must not reference environment-coupled paths.** Bad ACs reference paths that do not resolve in the agent's execution environment: paths under the user's home directory (`/Users/...`, `~/...`), absolute host paths outside the repo tree, or other host-only mounts. The DevContainer cannot reach the host filesystem, so the AC becomes unverifiable for the executing agent. Reference repo-relative paths, public URLs, or content the agent produces inside the container. If the AC genuinely needs a host-only resource, gate that resource under Prerequisites with a verify command, then phrase the AC as an observation of repo-relative artifacts the agent generates from it.

Bad (env-coupled path):

> - [ ] Output cites entries from `/Users/me/Engineering/research/`

Good (repo-relative or URL):

> - [ ] Output cites entries from `docs/research/` or named public URLs

**ACs must state positive structural constraints, not lists of prohibitions.** Bad ACs phrase the primary observable as what the output must NOT contain ("no preamble, no apology, no trailing pleasantries"). Prohibition-led framing is gameable: the agent satisfies each prohibition by omission without ever producing the substantive output. A positive tail tacked on the end ("only X, Y, Z") is not enough when the prohibitions carry the bulk of the AC. Lead with the positive shape: name the sections, name the order, name the first line if it matters.

Bad (negative-only):

> - [ ] The comment contains no preamble, no apology, no trailing pleasantries; only the candidate table, the persona verdicts, the recommendation

Good (positive structural):

> - [ ] The comment contains exactly four top-level sections in this order: a candidate table, a research-grounding block, persona verdicts, a recommendation block, and nothing else

**AC editing convention: delete the old AC, do not strike through.** When rewriting or superseding an AC, remove the old AC text entirely from the checklist. Do not use ~~strikethrough~~ formatting. Struck-through text is still rendered in GitHub's task list and confuses agents into counting it as a live check. The PR or a comment can note what changed and why; the issue body should only contain the current, active ACs.

## 5. Prerequisites for Autonomous Execution

Prerequisites describe **human setup** required before an agent can run the issue end to end (accounts, API keys, auth states, manual approvals). All items must be checked before moving the issue to Todo.

- Inter-issue dependencies are not prerequisites. Use GitHub native `blocked_by` instead. Add via the GraphQL `addBlockedBy` mutation:
  ```bash
  gh api graphql -f query='mutation($i:ID!,$b:ID!){ addBlockedBy(input:{issueId:$i, blockingIssueId:$b}){ issue { number } blockingIssue { number } } }' -f i=<issue_node_id> -f b=<blocking_issue_node_id>
  ```
  Inspect the graph via `Issue.blockedBy` / `Issue.blocking` GraphQL fields. Forward-refs to other issues do not belong in the Prerequisites checklist.

  **Warning:** `sub_issues_summary` (the convenience field on REST issue responses) and `trackedInIssues` (the tracking sidebar field) do NOT surface `blocked_by` relationships. An issue with zero `sub_issues_summary.total` may still have blockers. Always query `Issue.blockedBy` directly to check for blocking dependencies; do not infer absence of blockers from sub-issue or tracking counts
- Leave the section empty (not missing) when the issue is fully autonomous

**Prerequisite evidence convention.** When checking off a prerequisite, add indented sub-bullets so the agent can verify or reuse the setup:

```markdown
- [x] Human creates account manually (requires email verification)
  - Account URL: `https://example.com/factory-product`
  - Email used: `hello@<factory-product>.example`
  - Auth state: `~/.playwright/auth/<factory-product>-headed-expires-YYYY-MM-DD.json`
  - Verify: `ls ~/.playwright/auth/<factory-product>-*` confirms file exists
```

Each checked prerequisite should include one or more of:

- Verify command the agent can run (`ls`, `curl`, `dig`, `which`, `gh issue view`)
- Reference URL or path the agent can check exists
- Cross-reference to a dependency issue that is **already closed** at authoring time (`#NNN done`). In-flight inter-issue dependencies belong in GitHub `blocked_by`, not in the prereq list
- Context values (account names, dates, config details) the agent needs for execution

## 6. KR linking

- Only link issues to KRs at creation time, via the dual-agent ideation process driven from the prompts in [`prompts/`](../prompts/)
- Never retroactively link existing issues to KRs
- Standalone bug or chore issues do not need a KR link

## 7. Labels

Add `--label needs-visual-verification` at creation if the issue describes user-facing behavior (UI, chat messages, generated images, payment flows). Omit for infra, DX, CI, or tooling changes. The autonomous workflow's Verify phase only runs on labeled issues.

## 8. Closed-completed hygiene

Enforced by `audit-issues`:

- Closed-completed issues must have all pre-merge AC checkboxes ticked. Either mirror verification evidence into the body, or re-close as `NOT_PLANNED` so `stateReason` records the outcome honestly
- Closed-completed issues must have all prerequisite checkboxes ticked. If the issue closed as completed, the setup happened; the ticked boxes are the audit trail
- Exemptions: parent issues (no ACs) and closures with `stateReason != COMPLETED`

## 9. Project fields at creation

New issues land on the Solo Project automatically. Set Status, Priority, Effort, Work, and Cycle at creation time whenever those values are known. Leave a field null only when genuinely untriaged and there is no defensible value to set.

- Set fields at creation. The author (founder, or an agent acting under explicit founder direction) sets Status, Priority, Effort, Work, and Cycle inline with `gh api graphql` `updateProjectV2ItemFieldValue` mutations or via the GitHub UI as part of the same authoring session. Do not defer triage when the answers are obvious from the cycle plan, the OKR linkage, or the work scope
- Default Status=Backlog. Promote to Status=Todo only when prerequisites are ticked, ACs are written, and Priority + Effort + Work are set. Promotion is the agent-ready gate
- The `/issue-create` skill remains conservative: when invoked without explicit field values it leaves fields null, because Priority and Effort are human judgment calls and skill-side auto-filling produces bad rankings. The skill not auto-filling is not a license for callers to leave fields null when the values are known
- `pipeline-health.sh` enforces: Todo items must have Priority, Effort, and Work set. Leaving fields null is only correct for untriaged Backlog items

### Field option enums

| Field | Options | Semantics |
|-------|---------|-----------|
| Status | `Backlog`, `Todo`, `Setup`, `In Progress`, `Blocked`, `In Review`, `Fixing`, `Pre-Merge`, `Post-Merge`, `Done` | Workflow stage. New issues default to `Backlog`. Promote to `Todo` only when prereqs ticked + ACs written + Priority/Effort/Work set |
| Priority | `P0`, `P1`, `P2`, `P3` | P0 = drop everything, P1 = current cycle must-do, P2 = current cycle if capacity, P3 = backlog candidate |
| Effort | `S`, `M`, `L` | S ≤ 2h, M ≈ half-day, L ≥ 1 day. Sizes the work, not the impact |
| Work | `Agent`, `Human` | Who executes. `Agent` = autonomous workflow can take it end-to-end. `Human` = founder-only (account creation, design call, payment, manual auth, anything outside the agent's reach) |
| Cycle | iteration | Set to current iteration only when scheduling into the active cycle. Leave null for backlog candidates |
| Start date / End date | date | Set when promoting to `Todo` for the same day. End date = expected close (often `Start = End = today` for an S item starting now) |

## 10. Discipline

- Do not discuss or propose changes to OKR structure, priorities, or strategy in issue bodies. Execute the current plan; do not redesign it
- Batch changes, test locally, push once. Do not open a new issue for every small fix that can ride in an existing PR
