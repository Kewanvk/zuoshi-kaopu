---
name: vkskill-research
description: |
  Full research workflow. Trigger on "研究", "research", "调查", "deep research", or when the user wants a topic investigated through source gathering, claim ledger, adversarial challenge, NotebookLM verification, and final judgment.
---

# vkskill-research

Run the full proof workflow.

Read `../vkskill-proof/references/methodology.md` before starting.

## Workflow

Follow the methodology file. The short version:

1. Contract: ask purpose and depth.
2. Coverage Matrix: decide what dimensions must be covered.
3. Source gathering: use `../vkskill-source/SKILL.md`.
4. Hypotheses and Claim Ledger: keep claims marked `unverified`.
5. Challenge: use `../vkskill-challenge/SKILL.md`.
6. Verify: use `../vkskill-verify/SKILL.md`.
7. Freeze standards and run the five-question check.
8. Deliver final judgment with evidence trail.

## Mode Selection

Use lightweight mode for low-risk, small-source tasks.

Use standard mode by default.

Use audit mode for decisions that affect money, reputation, law, medicine, or public publishing.

## Outputs

Use files as the handoff surface:

- `01-brief.md`
- `02-coverage.md`
- `03-claims.md`
- `04-challenge.md`
- `05-evidence.md`
- `06-final.md`

For user-facing reports, follow the user's document format rules if present.
