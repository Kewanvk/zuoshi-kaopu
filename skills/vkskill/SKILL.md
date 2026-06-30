---
name: vkskill
description: >
  Main entry for Kewan's evidence workflows. Trigger on "vkskill" or
  "可万工具" for first-time setup, introduction, and routing.
  Trigger on "搜证" or "gather sources" for source gathering: tiered web
  fetching that preserves original text for later verification.
  Trigger on "脑暴" or "brainstorm" for adversarial challenge: a second model
  finds blind spots, unstated assumptions, and logical gaps in your thinking.
  Trigger on "质证" or "verify against sources" for evidence verification:
  NotebookLM checks your claims against source documents and returns exact
  quotes with confidence levels. Trigger on "研究" or "research" followed by
  a topic for the full research flow (methodology.md) that chains all three.
  Legacy triggers "做事靠谱" and "zuoshi-kaopu" still route here.
version: 5.0.0
---

# vkskill

**Language rule: match the user's language. Follow the user's lead.**

## Routing

**No `00-config.md` in current project:** Run Section A (First Run).

**"搜证" / "gather sources" / "找材料":** Run Section B (Source Gathering).

**"脑暴" / "brainstorm" / "challenge this":** Run Section C (Adversarial Challenge).

**"质证" / "verify" / "check against sources":** Run Section D (Evidence Verification).

**"研究" / "research" / "调查" + topic:** Read `references/methodology.md` and
follow the full Step 0 through Step 5 procedure, calling Section B/C/D as needed.

**"vkskill" / "可万工具" with existing config:** Show a brief reminder of the
commands and check if environment is still valid.

**"做事靠谱" / "zuoshi-kaopu":** Treat as legacy aliases for `vkskill`.

---

## Section A: First Run

Runs once per project. Two things happen: introduce the product, detect and
configure the environment.

### A1: Introduction

Present to the user:

> **vkskill** 是你工作中随时可以拉出来的三个动作。
>
> **搜证**：你需要从网上找材料时，说"搜证"。我会搜索、快速筛选、然后对值得
> 深入的源抓取完整原文存到本地，同时灌进 NotebookLM。后面质证的时候有据可查。
>
> 比如：
> - 你要研究一个行业，需要从零开始找材料
> - 你手上有几个链接，想把原文完整保存下来
> - 你需要给 NotebookLM 批量灌源
>
> **脑暴**：你觉得自己的想法可能有盲区时，说"脑暴"。我会把你的想法
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
> 说"研究 + 话题"可以跑完整流程：搜证 → 脑暴 → 质证，一条线串起来。
>
> **怎么用**：不需要专门打开这个 skill。在你做任何工作的过程中，
> 觉得某个地方不踏实，直接说"搜证""脑暴"或"质证"就行。

### A2: Environment Detection (background)

While showing A1, detect:
1. NotebookLM MCP tools available? (notebook_list, notebook_query, source_add)
2. Second model MCP servers or API configurations?
3. curl and textutil available? (macOS built-in, should be present)
4. Playwright / Chromium available? (optional, for JS-rendered sites)

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

Write `00-config.md` with: platform, NLM status, second model config,
source-fetching tools status, date.

Tell the user:

> 配置完成。现在继续你的工作就好。
> 需要找材料时，说"搜证"。
> 觉得想法需要被挑战时，说"脑暴"。
> 觉得结论需要查证据时，说"质证"。
> 要从头做一个完整研究，说"研究 + 话题"。

---

## Section B: Source Gathering ("搜证")

### Why this section exists

WebFetch returns AI summaries that lose ~93% of content (tested: a 3000-word
article becomes a 200-word summary). Evidence verification with NLM requires
original text. This section uses a two-phase approach: fast AI filtering
(where lossy is fine) then faithful full-text capture (where every word matters).

### B1: Understand what to gather

If the user said "搜证" with a topic, use it directly.
If they gave specific URLs, skip to B3.
If they just said "搜证", ask:

**"你要找什么方向的材料？有具体的链接还是需要从搜索开始？"**

### B2: Search and filter

1. **Search:** `WebSearch` with targeted queries based on the topic. Prioritize
   primary sources (official blogs, original papers, author posts) over
   secondary reporting.

2. **Quick filter:** `WebFetch` each URL with a relevance-check prompt. The AI
   summary is lossy but sufficient for judging "is this worth reading in full?"

3. **Select high-value sources:** Based on relevance, source grade (A/B/C/D per
   `references/source-grading.md`), and coverage needs. The number is not fixed.
   It depends on how many gaps remain and whether information is saturating.

### B3: Deep capture

For each selected URL, run a three-layer waterfall to get faithful original text:

**Layer 1: curl + textutil** (fast, zero-dependency on macOS)
```
curl -sL URL > raw/original/filename.html
textutil -convert txt raw/original/filename.html -output raw/extracted/filename.txt
```

**Layer 2: Playwright headless** (if curl gets 403, empty content, or JS-rendered shell)
```
Playwright chromium → navigate → wait for content → extract article innerText
```

**Layer 3: Record as unfetched** (if Playwright also fails: WAF, captcha, login wall)
```
Append to raw/00-unfetched-sources.md with URL, reason, and "manual retrieval needed"
```

### B4: Save locally

Save captured content to `raw/extracted/` with a metadata header:

```markdown
---
source: [original URL]
captured: [date]
method: curl+textutil | playwright | manual
---

[full text content]
```

### B5: Load into NLM

For each source, try `source_add(source_type=url, url=URL)`.

**If NLM URL loading fails** (common with Chinese sites):
fall back to `source_add(source_type=file, file_path="raw/extracted/xxx.md")`.

The local file serves double duty: raw archive AND NLM upload fallback.

**Confirm each source loaded successfully.** Report any that failed both paths.

### B6: Output

Outputs:
- `raw/extracted/*.md` local copies with metadata headers
- `raw/00-unfetched-sources.md` (if any sources could not be auto-fetched)
- NLM notebook with all sources loaded (URL or file)

---

## Section C: Adversarial Challenge ("脑暴")

### C1: Understand context

If the user said "脑暴" with context (e.g., "脑暴一下我这个方案"), use that
context directly. If they just said "脑暴", ask:

**"你现在在想什么？哪个地方让你觉得不太踏实？"**

Do not ask for a formal research question. Accept messy, half-formed thoughts.

### C2: Execute challenge

Send the user's thinking to the second model (from `00-config.md`) or a
sub-agent with this adversarial protocol:

**Instructions for the challenger:**
1. Find blind spots and unstated assumptions
2. Identify logical gaps and weak reasoning
3. Ask hard questions the user has not considered
4. Classify each finding: logic risk / evidence risk / execution risk
5. **Do NOT provide replacement solutions or alternative plans**
6. **Do NOT validate or praise. Your job is to find problems.**

### C3: Return results

Present the challenger's findings to the user. For each finding, show:
- What was challenged
- Why it might be a problem
- Risk type (logic / evidence / execution)

End with an optional prompt:

> 这里面有几个论断可能值得质证（用源材料验证）。要继续吗？

If the user says yes, transition to Section D with those claims pre-loaded.
If not, end here.

---

## Section D: Evidence Verification ("质证")

### D1: Understand what to verify

If the user said "质证" with a specific claim, use it directly.
If they just said "质证", ask:

**"你想验证哪个说法？材料在哪里？（已经在 NotebookLM 里的话告诉我 notebook 名字，
没有的话给我文件或链接）"**

### D2: Ensure sources are loaded

If sources are not yet in NLM, help load them:
- Files: `source_add(source_type=file)`
- URLs: `source_add(source_type=url)`
- Text: `source_add(source_type=text)`

### D3: Query and verify

For each claim the user wants verified:

1. Transform the claim into a specific, verifiable NLM query
2. Query NotebookLM
3. Re-query with rephrased question to confirm (extraction and verification
   are separate passes)
4. Three-layer check on each piece of evidence:
   - **Link works:** Is the source URL still accessible?
   - **Content relevant:** Does the source page actually discuss this topic?
   - **Fact supported:** Does the source text actually support this specific claim?
   (Research shows link validity stays at 94%+ while fact support drops to 39-77%.
   "Link works" does not mean "content supports.")
5. Return an evidence card:

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
- See `references/evidence-rules.md` for full rules.
- See `references/error-patterns.md` for common mistakes to avoid.

### D4: Multiple claims

If the user has multiple claims, process them one by one and present a summary
table at the end.

---

## Full Research Flow ("研究")

Not a separate section. When the user says "研究 + topic", read
`references/methodology.md` and follow the full Step 0 through Step 5 procedure.

Quick summary:

```
Step 0: Contract (2 questions: purpose + depth) → select mode
Step 1: Source gathering + Coverage Matrix (calls Section B)
Step 2: Hypotheses + Claim Ledger (claims without source → back to Step 1)
Step 3: Challenge + Verify in parallel (calls Section C + D)
Step 4: Freeze standards + 5-question check (user confirms "enough")
Step 5: Final synthesis + delivery
```

See `references/methodology.md` for the complete procedure, loop behaviors,
dual-layer standards, Coverage Matrix format, and three modes
(Lightweight / Standard / Audit).

---

## Reference Files

- `references/evidence-rules.md` : Evidence handling rules
- `references/error-patterns.md` : 8 common error patterns
- `references/source-grading.md` : Source reliability grading (A/B/C/D/X)
- `references/claim-ledger-template.md` : Evidence card format
- `references/methodology.md` : Full research workflow (v3, loop-enhanced)
- `references/setup/claude-code.md` : Setup for Claude Code
- `references/setup/codex.md` : Setup for Codex
