# OKR Exemplars (Few-Shot Context)

Generic exemplars drawn from past factory cycles. Refresh by replacing content below; no code changes needed.

---

## Objective Exemplar

### Title

Objective: Measurement instruments on every live product are verified end-to-end before any proof signal is interpreted

### Why

A prior cycle measured traffic attribution with no way to distinguish "no visitors arrived" from "the attribution filter is broken." Instrument and signal become indistinguishable when a measurement reads low and the instrument itself was never verified. A cycle must front-load instrument trust before any proof class is interpreted, otherwise market-evidence KRs are meaningless.

### What success looks like

By Day 3, each live product has: (1) a verified inbound channel for strangers to reach the founder, (2) an analytics traffic-baseline dashboard filtered to non-owner non-localhost, (3) a defined meaningful-session milestone event that fires on test sessions. On the primary product specifically, UTM attribution is verified end-to-end by injecting a known test pageview from a non-owner IP and confirming it appears in the relevant measure script output.

---

## KR Exemplar

**Track A — measurement readiness**

### Title

KR: UTM attribution instrument verified end-to-end on `<factory-product>`

### Measurement

Binary with partial. Inject a known `?utm_source=<channel>&utm_medium=verify&utm_campaign=c<N>trust` pageview on `<factory-product>` from a non-owner IP (playwright-cli with VPN or sandboxed browser context). Within the same-day query window, confirm the pageview appears in `scripts/measure/measure-kr<N>.sh` output. Commit evidence (query output, timestamps, source IP geo) to `logs/cycle-<N>-instruments/kr-<M>-utm-trust.md`.

Scoring:
- 1.0: test pageview appeared in measure script output with correct UTM source
- 0.5: test attempted, instrument returned negative, root cause diagnosed and documented (e.g., filter wrong, script wrong, ingestion lag)
- 0.0: test not attempted

Why graduated: a verified negative with diagnosis is cycle-N-valuable even if the instrument itself turned out broken; that is the kind of answer the prior cycle never got.

---

## Work-Issue Exemplar

### Title

Verify `<factory-product>` emits `$pageview` with UTM properties attached end-to-end

### Summary -- What & Why

UTM attribution only works if the landing page captures UTM params on the first `$pageview` and the analytics provider persists them. A prior cycle verified only the query side of the pipeline, not the **capture side**, so a low reading could have been either "no visitors" or "analytics SDK dropped the UTM params." This issue closes the capture-side gap.

### Acceptance Criteria (pre-merge)

- [ ] A Playwright test loads `https://<factory-product>.example/?utm_source=<channel>&utm_medium=verify&utm_campaign=c<N>trust` and asserts the browser emits a `$pageview` event containing those three UTM params
- [ ] An analytics API query for the same `distinct_id` returns an event with the expected `utm_source`, `utm_medium`, `utm_campaign` fields intact
- [ ] If there is a gap between what the browser emits and what analytics stores, the gap is documented in `logs/cycle-<N>-instruments/kr-<M>-utm-emit-verify.md` with a root-cause diagnosis (SDK drop / field rename / filter strip)

### Acceptance Criteria (post-merge)

- [ ] Manual: run the Playwright verification from a non-owner IP (VPN or playwright-cli sandboxed context) and confirm analytics receives the event with expected fields

### Prerequisites for Autonomous Execution

None -- fully autonomous.
