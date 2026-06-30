---
name: vkskill-challenge
description: |
  Challenge an idea and find blind spots. Trigger on "找漏洞", "脑暴", "brainstorm", "challenge this", "poke holes", "反驳一下", or when the user wants adversarial questions about a plan, argument, decision, or draft.
---

# vkskill-challenge

Challenge the user's thinking. Look for weak assumptions, logic gaps, evidence risks, and execution risks.

Do not fact-check here. Fact-checking belongs to `vkskill-verify`.

## Start

If the user provided context, use it.

If the user only said "找漏洞" or "脑暴", ask:

> 你现在在想什么？哪一块最不踏实？

Accept rough thoughts. Do not ask for a polished brief.

## Challenge Protocol

Use a second model, MiMo, or a subagent if available. If no second model is available, run a self-adversarial pass.

The challenger must:

1. Find hidden assumptions.
2. Identify logic gaps.
3. Ask hard questions the user has not considered.
4. Classify each issue as logic risk, evidence risk, or execution risk.
5. Avoid replacement plans.
6. Avoid praise.

## Output

Use this format:

```markdown
## 找漏洞结果

### 1. [challenged point]

问题：...
风险类型：logic | evidence | execution
为什么重要：...
下一步：可验证的具体问题
```

End by asking:

> 这里面有哪些说法要进入「验证说法」？
