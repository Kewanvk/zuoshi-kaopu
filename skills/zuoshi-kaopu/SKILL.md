---
name: zuoshi-kaopu
description: |
  Legacy alias for vkskill-proof. Trigger on old names "zuoshi-kaopu", "做事靠谱", "搜证", "脑暴", "质证", or "研究". Prefer the new vkskill skills, but keep this alias so existing installs continue to work.
---

# zuoshi-kaopu

This is the old name. The new name is `vkskill-proof`.

Do not run a separate workflow here. Route to the matching new skill file.

## Routing

| Old trigger | Read and follow |
|---|---|
| `做事靠谱`, `zuoshi-kaopu` | `../vkskill-proof/SKILL.md` |
| `搜证`, `找材料`, `找证据` | `../vkskill-source/SKILL.md` |
| `脑暴`, `找漏洞` | `../vkskill-challenge/SKILL.md` |
| `质证`, `验证说法` | `../vkskill-verify/SKILL.md` |
| `研究` plus a topic | `../vkskill-research/SKILL.md` |

If the new skill files are missing, tell the user to reinstall from the current `vkskill` repository.
