---
name: zuoshi-kaopu
description: >
  Use this skill when the user needs to research, analyze, or verify information
  from documents, reports, recordings, or web sources. Triggers include: "research
  this", "verify these claims", "analyze this report", "fact-check", "extract data
  from these files", "cross-verify", "write a research report", or any task where
  conclusions must be traceable to source evidence. Produces a Claim Ledger where
  every conclusion has a source, verification status, and confidence level.
version: 1.0.0
---

# zuoshi-kaopu

A research methodology that combines the broad knowledge of LLMs with the
grounded accuracy of NotebookLM. Every conclusion is traceable to source evidence
through a Claim Ledger.

**Core principle:** LLMs are hypothesis engines (smart but hallucination-prone).
NotebookLM is an evidence engine (accurate but narrow). This skill makes them
work together so you get intelligence you can trust.

## Step 0: Environment Setup (first run only)

Before starting any research, confirm the user's tool availability.

### Required: NotebookLM MCP

NotebookLM is the evidence engine. Without it, this skill cannot run.

Ask the user: **"Do you have NotebookLM MCP installed?"**

- If yes: verify by checking if `notebook_list` or equivalent NLM tools are available
- If no: guide installation based on platform. Read `references/setup/claude-code.md`
  or `references/setup/codex.md` for platform-specific instructions

### Optional: Second LLM for adversarial challenge

A second LLM strengthens hypothesis testing through adversarial challenge.

Ask the user: **"Do you have access to a second AI model? (e.g., Codex, Claude, Gemini)"**

- If yes: configure as adversarial challenger (via MCP or `/codex consult`)
- If no: use a sub-agent with a contrarian prompt as fallback

In Audit mode, record the configuration in the project's `00-config.md`.
Standard and Lightweight modes skip this file.

## Five-Step Workflow

Read `references/methodology.md` for full details. The file names below are for
Audit mode. Standard and Lightweight modes use fewer, consolidated files (see
Three Modes below). Summary:

### Step 1: Research Brief + Source Loading

Define the research question, scope, risk level, and deliverable type. Then load
all source materials into NotebookLM.

Output: `01-brief-and-sources.md`

### Step 2: Hypothesis Generation

The LLM reads source materials and forms hypotheses, analysis frameworks, or
question lists. Begin building the Claim Ledger with status = unverified.

Output: `02-hypotheses.md` (includes initial Claim Ledger)

### Step 3: Adversarial Challenge (rule-triggered)

**Triggers automatically when any of these apply:**
- Research involves recommendations, rankings, or comparisons
- Research involves factual judgments about people or companies
- Research involves money, legal, or reputation decisions
- Source materials contain contradictory information

When none apply, skip to Step 4.

Send hypotheses to the second LLM (or sub-agent). Accept problems it identifies;
reject replacement solutions by default (regenerate from context instead).

Output: `03-challenge.md`

### Step 4: Evidence Verification

Query NotebookLM with specific, verifiable questions derived from each hypothesis.
Update the Claim Ledger with evidence.

For each claim, record four fields:
- **Conclusion**: what the evidence shows
- **Source quote**: exact passage from NLM
- **Source**: document name, page, or URL
- **Confidence**: `direct` / `indirect` / `no_data` / `source_conflict`

Extraction and verification must be separate passes. NLM's own synthesis is not
evidence; only the source text it quotes is.

Output: `04-evidence.md` (updated Claim Ledger)

### Step 5: Final Judgment + Delivery

Review the Claim Ledger. If verification contradicts key hypotheses, loop back
to Step 2 (revision trigger).

Otherwise, produce the deliverable with the Claim Ledger as appendix.

Output: `05-judgment.md` + `06-deliverable.*`

## Three Modes

| Mode | Trigger | Output files |
|------|---------|-------------|
| Lightweight | Low-impact conclusions + simple sources | `final.md` with inline citations |
| Standard | Default | `01-brief.md` + `02-claims.md` + `03-final.md` |
| Audit | High-impact conclusions OR complex/conflicting sources | Full file chain (00-06) + Claim Ledger |

**Trigger matrix:**

|  | Low-impact conclusions | High-impact conclusions |
|---|---|---|
| Simple sources | Lightweight | Standard |
| Complex / conflicting sources | Standard | Audit |

**High-impact** = involves money, legal, personnel, reputation decisions; will be
published externally; involves factual claims about people or companies.

## Quality Checklist (run before delivery)

Four checks. If any fails, fix before delivering.

1. **Does every key conclusion have a source quote from NLM?**
2. **Did any data come from training knowledge instead of sources?** (If so, mark
   it explicitly or remove it)
3. **Did verification target the most error-prone claims, or just the easy ones?**
4. **Are uncertain items marked with their confidence level?**

## Reference Files

- `references/methodology.md` : Full five-step workflow with file specs
- `references/evidence-rules.md` : Evidence discipline rules
- `references/error-patterns.md` : 8 common error patterns with examples
- `references/source-grading.md` : Source grading system (A/B/C/D/X)
- `references/claim-ledger-template.md` : Claim Ledger format and field definitions
- `references/setup/claude-code.md` : Setup guide for Claude Code users
- `references/setup/codex.md` : Setup guide for Codex users
