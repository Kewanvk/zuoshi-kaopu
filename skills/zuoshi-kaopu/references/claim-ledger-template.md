# Claim Ledger Template

## Format

The Claim Ledger is the central artifact of every research task. It tracks every
important conclusion from hypothesis through verification.

```markdown
## Claim Ledger

| ID | Claim | Status | Source Quote | Source | Confidence | Notes |
|----|-------|--------|-------------|--------|------------|-------|
| C1 | [conclusion text] | [status] | "[exact quote]" | [doc + location] | [level] | [optional] |
| C2 | ... | ... | ... | ... | ... | ... |
```

## Field Definitions

### ID
Sequential identifier (C1, C2, C3...). Stable across updates. Never reuse
a deleted ID.

### Claim
The conclusion or factual statement being tracked. Write it as a declarative
sentence: "Company X was founded in 2015" not "When was Company X founded?"

### Status

| Status | Meaning |
|--------|---------|
| `unverified` | Hypothesis stage. Not yet checked against sources |
| `confirmed` | NLM evidence directly supports this claim |
| `corrected` | Evidence supports a modified version of the original claim |
| `contradicted` | Evidence directly contradicts this claim |
| `no_data` | Sources contain no relevant information |
| `source_conflict` | Multiple sources give conflicting information |

### Source Quote
The exact passage NLM cited. Copy-paste, do not paraphrase. If no quote
is available, leave empty and set confidence accordingly.

### Source
Document name + specific location (page number, section heading, timestamp
for audio/video). Must be specific enough for a reader to find the passage.

### Confidence

| Level | Definition |
|-------|-----------|
| `direct` | Source quote explicitly states the claim |
| `indirect` | Source quote is related but requires inference |
| `no_data` | No relevant information found in sources |
| `source_conflict` | Sources disagree |

### Notes
Optional. Use for: what changed during correction, which sources conflict
and how, why a claim was added mid-process.

## Lifecycle

1. **Created** in Step 2 (Hypothesis Generation) with `status: unverified`
2. **Challenged** in Step 3 (Adversarial): new claims may be added, existing
   ones may be flagged for priority verification
3. **Updated** in Step 4 (Evidence Verification): status, source quote, source,
   and confidence filled in
4. **Finalized** in Step 5 (Final Judgment): all claims have a final status
5. **Delivered** as appendix to the final deliverable

## Compact Format (for lightweight mode)

When running in lightweight mode, embed claims inline instead of a separate table:

```markdown
Revenue exceeded $10M in 2025. [confirmed, direct: "Total revenue reached $10.3M"
(Annual Report 2025, p.12)]
```
