---
name: zuoshi-kaopu
description: >
  Trigger on: "做事靠谱", "靠谱研究", "reliable research", "research with
  verification", "zuoshi-kaopu" for the full guided workflow. Also trigger on
  single-step keywords: "脑暴" or "brainstorm" for adversarial challenge against
  a second model; "质证" or "verify against sources" for NotebookLM evidence
  verification. Produces a Claim Ledger where every conclusion has a source,
  verification status, and confidence level.
version: 1.1.0
---

# zuoshi-kaopu (做事靠谱)

**Language rule: match the user's language. Follow the user's lead.**

## Routing: first run vs. returning user vs. single-step

**On first trigger ever (no `00-config.md` in the current project):**
Run the First Run Experience (Section A).

**On subsequent triggers with "做事靠谱" / "靠谱研究" / "reliable research":**
Run the Full Workflow (Section C).

**On keyword trigger "脑暴" / "brainstorm":**
Run Single-Step: Adversarial Challenge (Section D1).

**On keyword trigger "质证" / "verify against sources":**
Run Single-Step: Evidence Verification (Section D2).

---

## Section A: First Run Experience

This runs once per project, when the user first triggers the skill.
Two things happen in parallel: introduce the product, and detect the environment.

### A1: Introduction (show to user)

Present the following to the user (in their language):

> **做事靠谱** is a research methodology that combines the broad thinking of
> LLMs with the grounded accuracy of NotebookLM.
>
> The core idea: LLMs are smart but hallucinate. NotebookLM only speaks from
> source text. This skill makes them work together so your conclusions are
> traceable and trustworthy.
>
> **Two ways to use it:**
>
> 1. **Full workflow** ("做事靠谱"): I guide you step by step from research
>    question to verified deliverable. Every conclusion gets a Claim Ledger
>    entry with source, status, and confidence.
>
> 2. **Single-step** (use anytime during your work):
>    - Say **"脑暴"** when you want a second model to challenge your thinking.
>      I will send your ideas to another AI for adversarial review.
>    - Say **"质证"** when you want to verify a claim against source materials.
>      I will query NotebookLM for evidence and tell you what the sources
>      actually say.
>
> You do not need to have everything prepared upfront. Start with a rough idea
> and we build from there.

### A2: Environment Detection (run in background while showing A1)

While presenting the introduction, detect available tools:

1. **Check NotebookLM MCP**: are NLM tools (notebook_list, notebook_query,
   source_add) available?
2. **Check for second model**: are there other model MCP servers or API
   configurations available?

### A3: Environment Setup (after introduction)

Present detection results and guide the user through what is missing.

**NotebookLM (required):**

If not detected, guide installation:

> NotebookLM is the evidence engine. It is free with a Google account.
>
> ```
> pipx install notebooklm-mcp-cli
> nlm login
> nlm setup add <your-platform>
> ```
>
> (Read `references/setup/claude-code.md` or `references/setup/codex.md`
> for detailed steps.)

Do not proceed until NLM is confirmed working.

**Second model (recommended):**

Ask the user how they access AI models:

> To challenge your thinking from a different angle, a second model helps.
> How do you normally access AI?
>
> - **API aggregator** (SiliconFlow, OneAPI, OpenRouter): give me the base
>   URL and key, I can call Kimi, DeepSeek, Qwen, etc. through it
> - **Direct API key** (Anthropic, Google, Moonshot, etc.): I can call it
>   directly
> - **Another CLI tool** (Claude Code, Codex, Gemini CLI): I can cross-call
> - **Local model** (Ollama, LM Studio): I can call via local API
> - **None of the above**: I will do a self-critique pass instead (weaker
>   but still useful)

### A4: Save configuration

Write `00-config.md` in the current project directory with:
- Platform detected
- NLM status and notebook access
- Second model: what it is, how to call it, or "sub-agent fallback"
- Date configured

Tell the user: **"Setup complete. You can start using the skill now, or open
a new session when you are ready to do research."**

---

## Section B: Returning User Check

When the skill triggers and `00-config.md` already exists, read it and verify
the configuration is still valid (NLM accessible, second model reachable).
If anything changed, update `00-config.md`. Then proceed to Section C or D
based on the trigger keyword.

---

## Section C: Full Workflow (guided, step by step)

Triggered by "做事靠谱", "靠谱研究", "reliable research", or similar.

**Do not ask the user to provide everything at once.** Guide them one question
at a time:

### C1: Research Brief

Ask in sequence (wait for each answer before asking the next):

1. **"What do you want to research or figure out?"**
   Accept vague answers. Help the user sharpen the question if needed.

2. **"What materials do you have? (files, URLs, recordings, or nothing yet)"**
   If the user has materials, load them into NotebookLM.
   If not, help them think about where to find relevant sources.

3. **"What should the final output look like?"**
   Report? Decision memo? Verified fact list? Presentation notes?

4. **Determine mode** based on impact and source complexity:

   |  | Low-impact | High-impact |
   |---|---|---|
   | Simple sources | Lightweight | Standard |
   | Complex / conflicting | Standard | Audit |

   High-impact = money, legal, personnel, reputation, external publication,
   factual claims about people or companies.

Output: `01-brief-and-sources.md` (Audit) or inline (Lightweight/Standard)

### C2: Hypothesis Generation

Read source materials and form hypotheses. Start the Claim Ledger with all
claims marked `unverified`. Be explicit: these are hypotheses, not conclusions.

If the user is unsure what to ask: do an orientation scan first (list key
entities, topics, contradictions from the sources), then generate hypotheses.

Output: `02-hypotheses.md` with initial Claim Ledger

### C3: Adversarial Challenge (rule-triggered)

**Auto-triggers when any apply:**
- Recommendations, rankings, or comparisons
- Factual judgments about people or companies
- Money, legal, or reputation decisions
- Contradictory source materials

When none apply, skip to C4.

Send hypotheses to the second model (from `00-config.md`) or sub-agent.
Accept problems identified; reject replacement solutions (regenerate from
context instead).

Output: `03-challenge.md`

### C4: Evidence Verification

Query NotebookLM with specific questions for each claim. Update the Claim
Ledger. For each claim record: conclusion, source quote, source, confidence
(`direct` / `indirect` / `no_data` / `source_conflict`).

Extraction and verification are separate passes. NLM's synthesis is not
evidence; only quoted source text counts.

Output: `04-evidence.md` with updated Claim Ledger

### C5: Final Judgment + Delivery

If key claims are contradicted, loop back to C2.

Otherwise produce deliverable with Claim Ledger as appendix. Run the quality
checklist before delivering:

1. Every key conclusion has a source quote from NLM?
2. Any data from training knowledge instead of sources? (mark or remove)
3. Verification targeted the most error-prone claims?
4. Uncertain items marked with confidence level?

Output: `05-judgment.md` + `06-deliverable.*`

---

## Section D: Single-Step Modes

These can be triggered anytime during any conversation. They do not require
the full workflow. They use the environment from `00-config.md` if available;
if not, check NLM/model availability on the spot.

### D1: Adversarial Challenge ("脑暴")

Triggered by the user saying "脑暴", "brainstorm", "challenge this", or similar.

1. Ask: **"What idea or hypothesis do you want challenged?"**
2. Send to the second model (or sub-agent) with an adversarial prompt:
   find blind spots, unstated assumptions, alternative interpretations,
   logical gaps
3. Return results with clear labels: what was challenged, what holds up,
   what needs rethinking
4. Do NOT replace the user's ideas. Only surface problems. The user decides
   what to change.

### D2: Evidence Verification ("质证")

Triggered by the user saying "质证", "verify", "check against sources", or
similar.

1. Ask: **"What claim do you want verified, and against which sources?"**
2. If sources are not yet in NLM, help load them
3. Query NLM with specific, verifiable questions
4. Return results with: source quote, source location, confidence level
5. If NLM finds no evidence, say so explicitly. Do not fill gaps with
   training knowledge.

---

## Reference Files

- `references/methodology.md` : Full five-step workflow details
- `references/evidence-rules.md` : Evidence handling rules
- `references/error-patterns.md` : 8 common error patterns
- `references/source-grading.md` : Source reliability grading (A/B/C/D/X)
- `references/claim-ledger-template.md` : Claim Ledger format spec
- `references/setup/claude-code.md` : Setup guide for Claude Code
- `references/setup/codex.md` : Setup guide for Codex
