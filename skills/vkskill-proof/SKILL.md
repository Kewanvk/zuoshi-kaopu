---
name: vkskill-proof
description: |
  vkskill evidence workflow entry. Use when the user says "vkskill-proof", "proof", "做事靠谱", "zuoshi-kaopu", or asks for a proof/evidence workflow. Routes to three actions: find evidence, challenge assumptions, verify claims, plus full research mode.
---

# vkskill-proof

This is the evidence workflow entry.

You route the user to one of four proof actions. Keep this entry light.

## The Three Actions

1. **找证据**: search, capture original text, and load sources into NotebookLM.
2. **找漏洞**: challenge an idea for blind spots, assumptions, and logic gaps.
3. **验证说法**: verify whether source documents support a specific claim.

Full research mode chains all three.

## Routing

| User intent | Read and follow |
|---|---|
| 找证据, 搜证, gather sources, find evidence, collect sources | `../vkskill-source/SKILL.md` |
| 找漏洞, 脑暴, brainstorm, challenge this, poke holes | `../vkskill-challenge/SKILL.md` |
| 验证说法, 质证, verify, check against sources | `../vkskill-verify/SKILL.md` |
| 研究, research, investigate plus a topic | `../vkskill-research/SKILL.md` |

## First Run Check

Before source loading or verification, check whether NotebookLM MCP is available:

1. Confirm `notebook_list`, `notebook_query`, and `source_add` tools exist.
2. If they are missing, read `references/setup/codex.md` and help the user set up NotebookLM.
3. Do not mark verification as ready until `notebook_list` succeeds.

For source grading and evidence rules, load reference files only when the selected workflow needs them.

## If The User Is Unsure

Ask:

> 你现在要找材料、挑战一个想法，还是验证某个说法？
