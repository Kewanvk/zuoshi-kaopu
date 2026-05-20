# Methodology

## Role Assignment

| Role | Who | Responsibility | Boundary |
|------|-----|----------------|----------|
| Hypothesis Engine | Current platform LLM (Claude / GPT / Gemini) | Read materials, generate hypotheses, design question frameworks, make final judgments | All factual outputs must be marked "unverified" until evidence confirms them |
| Adversarial Challenger (optional) | Second LLM via MCP, or sub-agent | Challenge hypotheses, ensure MECE coverage, break templates | No fact-checking (that is NLM's job). No taste/style tasks |
| Evidence Engine | NotebookLM via MCP | Grounded extraction, source-quote verification, fact-checking | NLM's own synthesis is not evidence. Only the source text it quotes counts |

## Step 1: Research Brief + Source Loading

### 1a: Define the Research Brief

Before loading any sources, establish:

- **Research question(s)**: What specific questions need answering?
- **Deliverable type**: Report? Table? Slides? Decision memo?
- **Audience**: Who will use this output?
- **Risk level**: Will conclusions affect money, legal, personnel, or reputation decisions?

Write these into `01-brief-and-sources.md` header section.

### 1b: Load Sources into NotebookLM

Source handling rules:

| Source type | Action |
|-------------|--------|
| PDF, audio recording | Upload directly to NLM via `source_add(source_type=file)` |
| Web URL | Add via `source_add(source_type=url)` |
| Local text / markdown | Add via `source_add(source_type=text)` |
| Crawled fragments (comments, posts, job listings) | Merge into a structured document with index, then upload as single file |
| Sensitive / confidential material | Ask user for explicit permission before uploading |

Different evidence types should go into separate notebooks or be clearly tagged
(e.g., company filings vs. interview transcripts).

Create notebook via `notebook_create`, then import sources. Record:
- Notebook ID
- List of all sources with source IDs and source grade (A/B/C/D/X per
  `references/source-grading.md`)
- Any sources that failed to import

Append source inventory to `01-brief-and-sources.md`.

## Step 2: Hypothesis Generation

The LLM forms hypotheses based on available context. For text-based sources,
the LLM can do a quick local scan. For PDFs and audio (which must stay in NLM
per evidence rules), use an orientation pass instead: review source titles,
the user's brief, and run a few targeted NLM queries to discover key topics,
entities, and contradictions. Then form hypotheses from this orientation.

The LLM produces:

- A list of hypotheses or candidate conclusions
- An analysis framework or question structure
- Initial observations and patterns

**Rules:**
- Never query NLM with vague, open-ended questions. Hypotheses give NLM something
  specific to confirm or deny
- Mark everything as "unverified"
- If the user says "I don't know what to ask" or the material is unfamiliar:
  run an orientation pass (list key entities, topics, contradictions via targeted
  NLM queries), then generate hypotheses from the results

**Begin the Claim Ledger.** Each hypothesis becomes a claim entry with
`status: unverified`. See `references/claim-ledger-template.md` for format.

Output: `02-hypotheses.md`

## Step 3: Adversarial Challenge (rule-triggered)

### Trigger conditions (any one triggers this step)

- Research involves recommendations, rankings, or comparisons
- Research involves factual judgments about people or companies
- Research involves money, legal, or reputation decisions
- Source materials contain contradictory information

When none apply, skip to Step 4.

### Execution

Send `02-hypotheses.md` plus relevant context to the adversarial challenger:

- **If second LLM available**: use MCP or `/codex consult`. Include the full
  hypothesis list and background constraints
- **If no second LLM**: spawn a sub-agent with a contrarian system prompt.
  The sub-agent should try to find blind spots, unstated assumptions, and
  alternative interpretations

### Return-flow rules

| What they return | How to handle |
|-----------------|---------------|
| Problems they identify | Take seriously. These often have real value |
| Replacement solutions | Do not adopt directly. Regenerate solutions from your own context |

For each item, annotate: adopted (with reason) or rejected (with reason).

Output: `03-challenge.md`

## Step 4: Evidence Verification

### 4a: Query Design

Transform each claim in the Claim Ledger into specific, verifiable NLM queries.

**Good queries (specific, verifiable):**
- "Does the annual report state revenue exceeded $10M in 2025?"
- "According to the transcript, did the speaker say X?"
- "Which document mentions the company's founding year?"

**Bad queries (vague, invites inference):**
- "Tell me about the company's financials"
- "What do the sources say about X?"

### 4b: Extraction Pass

For each claim, query NLM and record four fields:

| Field | Description |
|-------|-------------|
| Conclusion | What the evidence shows |
| Source quote | Exact passage NLM cited |
| Source | Document name + location (page, section, timestamp) |
| Confidence | `direct` / `indirect` / `no_data` / `source_conflict` |

**Confidence definitions:**
- `direct`: NLM cited a passage that explicitly states the conclusion
- `indirect`: NLM cited a related passage; conclusion requires inference
- `no_data`: NLM found no relevant information in sources
- `source_conflict`: Multiple sources contradict each other

### 4c: Verification Pass (separate from extraction)

Re-query NLM with rephrased questions for all `indirect` and a 20% sample of
`direct` claims. Compare answers:

| Scenario | Action |
|----------|--------|
| Both answers agree with citations | Confirm claim |
| Answers agree but second has no citation | Keep as `indirect` |
| Answers contradict | Flag as `source_conflict`, investigate |
| Second query returns nothing | Original may have been over-interpreted |

Update Claim Ledger statuses:
`unverified` -> `confirmed` / `corrected` / `contradicted` / `no_data` / `source_conflict`

Output: `04-evidence.md` (contains the updated Claim Ledger)

## Step 5: Final Judgment + Delivery

### Revision trigger

If verification contradicts key hypotheses (any claim central to the main
conclusion is `contradicted` or `source_conflict`), loop back to Step 2.
Generate new hypotheses incorporating what the evidence actually shows.

### Final synthesis

For each claim in the Claim Ledger:
- `confirmed`: include in deliverable with source reference
- `corrected`: include corrected version with note on what changed
- `no_data`: include with explicit "no evidence found" label. Do not fill gaps
  with training knowledge
- `source_conflict`: present both sides with sources
- `contradicted`: exclude from conclusions or present as disproven

### Deliverable

Produce the requested output format (report, table, memo, slides, etc.) with:
- Main content drawing only from verified claims
- Claim Ledger as appendix (or inline for short outputs)
- Footer noting this output was produced using the hypothesis-evidence methodology

Output: `05-judgment.md` + `06-deliverable.*`

## Three Modes: Detailed Rules

### Lightweight Mode

**When:** Low-impact conclusions + simple sources (1-2 documents, fewer than 5 questions, no high-stakes decisions).

**Simplified flow:**
- Steps 1+2 merge: brief + hypotheses in one file
- Step 3 skipped
- Steps 4+5 merge: verify and deliver in one pass
- Claim Ledger embedded inline (no separate file)

**Output:** Single `final.md` with inline citations.

### Standard Mode

**When:** Default for most research tasks.

**Full flow but with consolidated files:**
- `01-brief.md`: research question + sources
- `02-claims.md`: hypotheses + Claim Ledger (extraction + verification combined)
- `03-final.md`: judgment + deliverable

### Audit Mode

**When:** High-impact conclusions OR complex/conflicting sources. Specifically:
- Conclusions affect money, legal, personnel, or reputation decisions
- Output will be published externally or shared with stakeholders
- Source materials contain contradictions or come from mixed-reliability sources
- More than 5 source documents

**Full flow with complete file chain:**
- `00-config.md`: environment setup record
- `01-brief-and-sources.md`: research brief + full source inventory
- `02-hypotheses.md`: all hypotheses + initial Claim Ledger
- `03-challenge.md`: adversarial review (if triggered)
- `04-evidence.md`: complete verification record
- `05-judgment.md`: final synthesis with revision notes
- `06-deliverable.*`: clean deliverable for end audience
- Claim Ledger maintained as running artifact through 02-05
