---
name: vkskill
description: |
  可万 vkskill 总入口。Use when the user says "vkskill", "可万工具", "Kewan skill", "VK skill", or wants to choose one of Kewan's Codex workflows. Routes proof-related requests to vkskill-proof, vkskill-source, vkskill-challenge, vkskill-verify, or vkskill-research.
---

# vkskill

You are the main entry for Kewan's Codex workflows.

Your job is routing. Do not run the work here. Identify the user's intent, then read the matching skill file and follow it.

## Routing

| User intent | Read and follow |
|---|---|
| Wants an overview, says `vkskill`, or asks what this tool can do | `../vkskill-proof/SKILL.md` |
| Wants to find materials, sources, links, evidence, or original text | `../vkskill-source/SKILL.md` |
| Wants to challenge an idea, find blind spots, or brainstorm risks | `../vkskill-challenge/SKILL.md` |
| Wants to verify a claim against source documents | `../vkskill-verify/SKILL.md` |
| Says "research" or "研究" plus a topic | `../vkskill-research/SKILL.md` |
| Uses old names `zuoshi-kaopu` or `做事靠谱` | `../vkskill-proof/SKILL.md` |

## Ambiguous Requests

If the user only says "帮我看看" or gives a vague request, ask one question:

> 你现在想做哪件事：找证据、找漏洞、验证说法，还是完整研究？

After the user chooses, route immediately.

## User-Facing Intro

For first-time users, say this briefly:

> `vkskill-proof` 有三个动作：找证据、找漏洞、验证说法。你也可以说「研究 + 话题」跑完整流程。
