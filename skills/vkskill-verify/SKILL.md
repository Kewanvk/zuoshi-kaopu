---
name: vkskill-verify
description: |
  Verify claims against source documents with NotebookLM. Trigger on "验证说法", "质证", "verify", "check against sources", "有没有原文支撑", or when the user wants evidence quotes, citations, verdicts, and confidence levels for one or more claims.
---

# vkskill-verify

Verify whether source documents support a specific claim.

Read these references before verification:

- `../vkskill-proof/references/evidence-rules.md`
- `../vkskill-proof/references/error-patterns.md`
- `../vkskill-proof/references/claim-ledger-template.md` if there are multiple claims

## Start

If the user gave a claim, use it.

If the user only said "验证说法" or "质证", ask:

> 你想验证哪个说法？材料在哪里？如果已经在 NotebookLM 里，告诉我 notebook 名字。

## Source Readiness

If sources are not loaded into NotebookLM, load them first:

- URLs: `source_add(source_type=url)`
- files: `source_add(source_type=file)`
- pasted text: `source_add(source_type=text)`

Ask before uploading sensitive material.

## Verification Pass

For each claim:

1. Convert the claim into a precise NotebookLM query.
2. Query NotebookLM.
3. Re-query with a different wording.
4. Check the source quote against the claim.
5. Separate link validity, topic relevance, and fact support.

Only quoted source text counts as evidence.

## Evidence Card

```markdown
Claim: [user claim]
Verdict: supported | partially supported | not found | contradicted
Evidence: "[exact quote]"
Citation: [source document + location]
Confidence: direct | indirect | no_data | source_conflict
What this does not prove: [limit]
```

For multiple claims, finish with a compact table.
