---
name: zuoshi-kaopu
description: >
  Trigger on "脑暴" or "brainstorm" for adversarial challenge: a second model
  finds blind spots, unstated assumptions, and logical gaps in your thinking.
  Trigger on "质证" or "verify against sources" for evidence verification:
  NotebookLM checks your claims against source documents and returns exact
  quotes with confidence levels. Trigger on "做事靠谱" or "zuoshi-kaopu" for
  first-time setup and introduction.
version: 2.0.0
---

# zuoshi-kaopu (做事靠谱)

**Language rule: match the user's language. Follow the user's lead.**

## Routing

**No `00-config.md` in current project:** Run Section A (First Run).

**"脑暴" / "brainstorm" / "challenge this":** Run Section B (Adversarial Challenge).

**"质证" / "verify" / "check against sources":** Run Section C (Evidence Verification).

**"做事靠谱" / "zuoshi-kaopu" with existing config:** Show a brief reminder of
the two commands and check if environment is still valid.

---

## Section A: First Run

Runs once per project. Two things happen: introduce the product, detect and
configure the environment.

### A1: Introduction

Present to the user:

> **做事靠谱**不是一个独立的研究工具。它是你日常工作中随时可以拉出来的两个动作。
>
> **脑暴**：你在工作中觉得自己的想法可能有盲区时，说"脑暴"。我会把你的想法
> 发给另一个 AI 模型，让它专门找漏洞、拆假设、提出你没考虑到的问题。
> 它只许提问，不许给你替代方案。你自己决定改不改。
>
> 比如：
> - 你写了一个商业方案，觉得定位不够锐利
> - 你做了一个分析，怀疑自己在套模板
> - 你要做一个重要决策，想听听反面意见
>
> **质证**：你说了一个结论，想确认源材料是不是真的支持它，说"质证"。
> 我会用 NotebookLM 去查你的源材料原文，告诉你：有没有证据、证据原文是什么、
> 这个证据能证明什么、不能证明什么。如果没有证据，我会直接说"没有"，不会编。
>
> 比如：
> - 你引用了一份报告里的数据，想确认原文是不是这么说的
> - 你写了一个论点，想知道你的材料里有没有支撑
> - 同事说了一个事实，你想查一下出处
>
> **怎么用**：不需要专门打开这个 skill。在你做任何工作的过程中，
> 觉得某个地方不踏实，直接说"脑暴"或"质证"就行。

### A2: Environment Detection (background)

While showing A1, detect:
1. NotebookLM MCP tools available? (notebook_list, notebook_query, source_add)
2. Second model MCP servers or API configurations?

### A3: Environment Setup

Present detection results and configure what is missing.

**NotebookLM (REQUIRED, must complete before skill is usable):**

If not detected:

> 质证功能需要 NotebookLM。它是免费的，用 Google 账号就行。
>
> 安装三步：
> ```
> pipx install notebooklm-mcp-cli
> nlm login
> nlm setup add <your-platform>
> ```

Read `references/setup/claude-code.md` or `references/setup/codex.md` for
detailed platform steps. **Do not mark setup as complete until NLM is
confirmed working (successfully call notebook_list).**

**Second model (recommended):**

> 脑暴功能用第二个模型效果最好。你平时怎么用 AI？
>
> - **API 中转站**（硅基流动、OneAPI、OpenRouter）：给我 base URL 和 key，
>   我可以通过它调用 Kimi、DeepSeek、通义千问等
> - **直接 API**（Anthropic、Google、Moonshot 等）：直接调用
> - **另一个 CLI 工具**（Claude Code、Codex、Gemini CLI）：跨工具调用
> - **本地模型**（Ollama、LM Studio）：本地 API 调用
> - **都没有**：我会用自我对抗模式代替（效果弱一些，但仍然有用）

### A4: Save and finish

Write `00-config.md` with: platform, NLM status, second model config, date.

Tell the user:

> 配置完成。现在继续你的工作就好。
> 觉得想法需要被挑战时，说"脑暴"。
> 觉得结论需要查证据时，说"质证"。

---

## Section B: Adversarial Challenge ("脑暴")

### B1: Understand context

If the user said "脑暴" with context (e.g., "脑暴一下我这个方案"), use that
context directly. If they just said "脑暴", ask:

**"你现在在想什么？哪个地方让你觉得不太踏实？"**

Do not ask for a formal research question. Accept messy, half-formed thoughts.

### B2: Execute challenge

Send the user's thinking to the second model (from `00-config.md`) or a
sub-agent with this adversarial protocol:

**Instructions for the challenger:**
1. Find blind spots and unstated assumptions
2. Identify logical gaps and weak reasoning
3. Ask hard questions the user has not considered
4. Classify each finding: logic risk / evidence risk / execution risk
5. **Do NOT provide replacement solutions or alternative plans**
6. **Do NOT validate or praise. Your job is to find problems.**

### B3: Return results

Present the challenger's findings to the user. For each finding, show:
- What was challenged
- Why it might be a problem
- Risk type (logic / evidence / execution)

End with an optional prompt:

> 这里面有几个论断可能值得质证（用源材料验证）。要继续吗？

If the user says yes, transition to Section C with those claims pre-loaded.
If not, end here.

---

## Section C: Evidence Verification ("质证")

### C1: Understand what to verify

If the user said "质证" with a specific claim, use it directly.
If they just said "质证", ask:

**"你想验证哪个说法？材料在哪里？（已经在 NotebookLM 里的话告诉我 notebook 名字，
没有的话给我文件或链接）"**

### C2: Ensure sources are loaded

If sources are not yet in NLM, help load them:
- Files: `source_add(source_type=file)`
- URLs: `source_add(source_type=url)`
- Text: `source_add(source_type=text)`

### C3: Query and verify

For each claim the user wants verified:

1. Transform the claim into a specific, verifiable NLM query
2. Query NotebookLM
3. Return an evidence card:

```
Claim: [the user's statement]
Verdict: supported / partially supported / not found / contradicted
Evidence: [exact quote from NLM]
Citation: [source document + location]
Confidence: direct / indirect / no_data / source_conflict
What this does NOT prove: [prevent over-interpretation]
```

**Rules:**
- NLM's own synthesis is not evidence. Only quoted source text counts.
- If NLM finds nothing, say "not found." Do not fill gaps with training knowledge.
- Extraction and verification are separate: query first, then re-query with
  rephrased questions to confirm.
- See `references/evidence-rules.md` for full rules.
- See `references/error-patterns.md` for common mistakes to avoid.

### C4: Multiple claims

If the user has multiple claims, process them one by one and present a summary
table at the end.

---

## Reference Files

- `references/evidence-rules.md` : Evidence handling rules
- `references/error-patterns.md` : 8 common error patterns
- `references/source-grading.md` : Source reliability grading (A/B/C/D/X)
- `references/claim-ledger-template.md` : Evidence card format
- `references/methodology.md` : Full workflow (v2 reference, not active in MVP)
- `references/setup/claude-code.md` : Setup for Claude Code
- `references/setup/codex.md` : Setup for Codex
