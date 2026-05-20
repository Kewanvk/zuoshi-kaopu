# zuoshi-kaopu

**AI research with a claim ledger.**

Every conclusion is traceable to a source, a verification step, and a confidence level.

[中文版](README.zh-CN.md)

## What It Produces

Most AI research tools produce a polished report with citations. Citations can be decorative. This skill produces an **evidence trail first**, then a report.

The core artifact is a **Claim Ledger**:

```
| ID | Claim                        | Status     | Source Quote              | Source          | Confidence |
|----|------------------------------|------------|---------------------------|-----------------|------------|
| C1 | Revenue exceeded $10M        | confirmed  | "Total revenue: $10.3M"   | Annual Report   | direct     |
| C2 | Founded in 2015              | corrected  | "Incorporated March 2016" | SEC Filing      | direct     |
| C3 | Market leader in segment     | no_data    |                           |                 |            |
| C4 | Partnership with Company X   | source_conflict| conflicting statements   | Press + Filing  | indirect   |
```

Claims with `no_data` stay visible. They are not quietly dropped. That is the point.

## How It Works

LLMs are smart but hallucinate. NotebookLM is accurate but narrow. This skill makes them work together:

1. **Research Brief + Source Loading** : Define questions, load sources into NotebookLM
2. **Hypothesis Generation** : LLM reads materials, forms hypotheses, starts the Claim Ledger
3. **Adversarial Challenge** (auto-triggered) : Second LLM or sub-agent challenges the hypotheses
4. **Evidence Verification** : NotebookLM verifies each claim with source quotes
5. **Final Judgment + Delivery** : Synthesize verified claims into deliverable + Claim Ledger appendix

## When to Use

Use this skill when your output will be relied upon by others and you have source materials to process:

- Research reports and industry analysis
- Fact-checking claims from documents
- Analyzing interview transcripts or recordings
- Competitive and benchmark analysis
- Academic assignments and papers
- Any task where "I made it up" is not acceptable

## When Not to Use

- Pure creative work (no "right answer" exists)
- Brainstorming and exploration (hallucination is a feature, not a bug)
- Pure execution tasks (deploying, configuring, building)

## Three Modes

| Mode | When | Output |
|------|------|--------|
| Lightweight | Low stakes + simple sources | Single file with inline citations |
| Standard | Default | 3 files (brief, claims, final) |
| Audit | High stakes OR complex sources | Full file chain with complete Claim Ledger |

The skill selects the mode automatically based on impact and source complexity.

## Quick Start

### Claude Code

```bash
git clone https://github.com/Kewanvk/zuoshi-kaopu.git ~/zuoshi-kaopu
cd ~/zuoshi-kaopu && claude plugin add .

# Install NotebookLM MCP (required)
pipx install notebooklm-mcp-cli
nlm login
nlm setup add claude-code
nlm skill install claude-code
```

Then type `/zuoshi-kaopu` in Claude Code.

### Codex CLI

```bash
git clone https://github.com/Kewanvk/zuoshi-kaopu.git ~/zuoshi-kaopu
mkdir -p ~/.codex/skills
cp -r ~/zuoshi-kaopu/skills/zuoshi-kaopu ~/.codex/skills/zuoshi-kaopu

# Install NotebookLM MCP (required)
pipx install notebooklm-mcp-cli
nlm login
nlm setup add codex
```

Then type `/zuoshi-kaopu` in Codex.

See `skills/zuoshi-kaopu/references/setup/` for detailed platform guides.

## Dependencies

| Dependency | Required | Purpose |
|-----------|----------|---------|
| NotebookLM MCP | Yes | Evidence engine. Provides grounded, source-quoted verification |
| Second LLM (Codex/Claude/Gemini) | No | Adversarial challenge. Falls back to sub-agent if unavailable |

## Limitations and Trust Boundaries

- This skill does not search the internet on its own. It works with sources you provide. If you give it URLs or ask it to crawl specific pages, it will process those as sources
- NotebookLM free tier allows ~50 queries/day. Large projects may need multiple sessions
- The adversarial challenge catches blind spots but is not a substitute for domain expertise
- "Verified" means checked against provided sources, not checked against all possible sources
- The skill cannot verify claims that require visual inspection of non-text content

## Reference Files

| File | Purpose |
|------|---------|
| `references/methodology.md` | Full five-step workflow |
| `references/evidence-rules.md` | Evidence handling rules |
| `references/error-patterns.md` | 8 common error patterns |
| `references/source-grading.md` | Source reliability grading (A/B/C/D/X) |
| `references/claim-ledger-template.md` | Claim Ledger format spec |

## License

MIT
