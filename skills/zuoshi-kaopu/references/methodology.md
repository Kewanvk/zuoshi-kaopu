# Methodology v3 (Loop-Enhanced)

v3 改动：从线性五步改为带 Coverage Matrix 和验证门控的闭环结构。
基于 2026-06-19 Loop Engineering 研究的反思。

## Role Assignment

| Role | Who | Responsibility | Boundary |
|------|-----|----------------|----------|
| Hypothesis Engine | Current platform LLM (Claude / GPT / Gemini) | Read materials, generate hypotheses, design question frameworks, make final judgments | All factual outputs must be marked "unverified" until evidence confirms them |
| Adversarial Challenger (optional) | Second LLM via MCP, or sub-agent | Challenge hypotheses, ensure MECE coverage, break templates | No fact-checking (that is NLM's job). No taste/style tasks |
| Evidence Engine | NotebookLM via MCP | Grounded extraction, source-quote verification, fact-checking | NLM's own synthesis is not evidence. Only the source text it quotes counts |

---

## 双层标准（Dual-Layer Standards）

每个研究任务运行两层标准。契约层固定，操作层动态。

### 契约层（固定，人定，不随 Loop 改）

在 Step 0 采集，写入 `01-brief-and-sources.md` 头部，后续不修改。

两个必答问题：
1. **目的**：这个研究是为了理解，还是为了做决定？
2. **深度**：要快速概览，还是要形成独立判断？

可选追问（高风险场景）：
- 读者是谁？
- 结论会影响金钱/法律/声誉决策吗？
- 宁可遗漏还是宁可多查？

### 操作层（动态，系统维护，有门控）

在 Step 1 自动生成初版，执行中可修正。包含：
- 维度清单（Coverage Matrix 的行）
- 每个维度的最低证据要求
- 停止条件

**操作层变更门控**：新增维度必须满足以下至少一个条件：
- 它影响最终判断
- 它解释了已有资料中的矛盾
- 它被多个独立来源反复提到
- 它暴露了原标准的盲区
- 它是契约层目标下不可忽略的风险

不满足的记为「旁支」，不进入主流程。

---

## Coverage Matrix（覆盖矩阵）

每个研究任务的核心状态文件。维护在 `02-coverage.md` 中。

```markdown
## Coverage Matrix

| 维度 | 状态 | 当前结论 | 证据源 | 可信度 | 缺口/动作 |
|------|------|---------|--------|--------|----------|
| D1: [维度名] | covered / partial / empty | [一句话结论] | [源列表] | high/mid/low | [需要补什么] |
| D2: ... | ... | ... | ... | ... | ... |
```

状态定义：
- `empty`：还没搜到任何相关信息
- `partial`：有一些信息但不够支撑结论
- `covered`：有足够信息且经过验证

---

## 「够了」判断机制

### 单维度饱和信号（自动判断）

当同一维度的新搜索结果开始重复已有内容时，该维度信息饱和，标记为 `covered`。

### 整体完成检查（5问自检）

在进入最终综合之前，列出 5 个「聪明人看完这份研究后最可能追问的问题」，标注能否用现有资料回答：

```markdown
## 5问自检

| # | 聪明人会问的问题 | 能答吗 | 证据在哪 |
|---|----------------|--------|---------|
| 1 | [问题] | yes/partial/no | [源] |
| 2 | ... | ... | ... |
```

- 全部 yes：够了，进入最终综合
- 有 partial：标注为已知局限，可以继续
- 有 no：回到搜索补这个方向，或与用户确认是否跳过

用户扫一眼这张表就能决定「够了」还是「再补一块」。

---

## 工序（Loop 结构）

```
Step 0: 契约 ──────────────────────────────────────── 固定不变
   │
Step 1: 搜索 + Coverage Matrix ◄───────────────┐
   │                                            │
   ├─ 门控：Matrix 有 empty 行？──── yes ──► 补搜 ─┘
   │                      no
   │                      ▼
Step 2: 综合 + Claim Ledger
   │
   ├─ 门控：关键声明无源支撑？──── yes ──► 回 Step 1
   │                      no
   │                      ▼
Step 3: 脑暴 + 质证（并行）
   │
   ├─ 脑暴发现遗漏维度 ──► 过变更门控 ──► 加入 Matrix ──► 回 Step 1
   ├─ 质证发现不可靠声明 ──► 标注/补源
   │
   │  门控：所有回流处理完毕
   │                      ▼
Step 4: 冻结 + 5问自检
   │
   ├─ 冻结操作层标准（不再新增维度）
   ├─ 5问自检 ──► 用户确认
   │                      ▼
Step 5: 最终综合 + 交付
```

---

## Step 0: Research Contract

两个必答问题（见双层标准 - 契约层）。

写入 `01-brief-and-sources.md` 头部。

---

## Step 1: Search + Coverage Matrix

### 1a: Generate Initial Coverage Matrix

基于契约层目标，自动生成初始维度清单。

常用维度模板（按需选用，不是全部都要）：
- 概念定义
- 起源/提出者
- 演化路径
- 实践案例
- 争议/反面观点
- 数据/证据
- 与用户工作的关联
- 风险/局限

写入 `02-coverage.md`。

### 1b: Search + Source Loading

按 Coverage Matrix 的 empty 行确定搜索方向。

搜索规则：
- 优先一手源（官方博客、作者原文、学术论文）
- 所有外部内容落盘到 `raw/` 目录，带原始 URL
- URL 也灌入 NLM
- 每搜完一批，更新 Coverage Matrix

Source loading 规则同 v2（见下方 Source Handling）。

### 1c: 饱和检查

每轮搜索后检查：
- 新结果是否在重复已有内容？（饱和信号）
- Coverage Matrix 是否还有 `empty` 行？

有 empty 行且未饱和 → 继续搜索。
全部 `partial` 或 `covered` → 进入 Step 2。

---

## Step 2: Hypothesis + Claim Ledger

LLM 基于已有资料形成初步判断。

产出：
- 假设/候选结论列表
- Claim Ledger 初版（每条标 `unverified`）
- 更新 Coverage Matrix（从 empty → partial 或 covered）

**门控**：每个关键声明（影响最终判断的）是否都有至少一个 raw/ 源支撑？
- 有无源支撑的声明 → 回 Step 1 补搜
- 全部有源 → 进入 Step 3

Output: `03-hypotheses.md`

---

## Step 3: Adversarial Challenge + Evidence Verification

两条线并行执行。

### 3a: Adversarial Challenge（脑暴）

触发条件同 v2（涉及推荐/排名/金钱/声誉决策时触发，否则可选）。

发送假设列表 + 上下文给 challenger。

**回流处理**：
- Challenger 发现的遗漏维度 → 过变更门控 → 通过则加入 Coverage Matrix → 回 Step 1 补搜
- Challenger 发现的逻辑漏洞 → 更新假设
- Challenger 的替代方案 → 不直接采用，记录为参考

Output: `04-challenge.md`

### 3b: Evidence Verification（质证）

拿 Claim Ledger 中的 `unverified` 声明逐条去 NLM 验证。

查询设计、提取、验证规则同 v2（见 references/evidence-rules.md）。

**回流处理**：
- `no_data` → 标注，考虑补源
- `contradicted` 且影响核心结论 → 回 Step 2 重新假设
- `source_conflict` → 记录双方，进入最终判断

更新 Claim Ledger 状态。
更新 Coverage Matrix 可信度列。

Output: `05-evidence.md`

---

## Step 4: Freeze + 5-Question Check

### 4a: 冻结操作层标准

从此刻起：
- 不再新增 Coverage Matrix 维度
- 只允许为现有声明补充证据
- 只允许标注不确定性

### 4b: 5问自检

列出 5 个「聪明人会问的问题」，标注覆盖情况，呈给用户确认。

用户说「够了」→ 进入 Step 5。
用户说「这块再补一下」→ 回 Step 1 补搜（但不新增维度，只补证据）。

---

## Step 5: Final Judgment + Delivery

### Revision trigger

如果 Step 3 验证推翻了关键假设，回到 Step 2。

### Final synthesis

对 Claim Ledger 每条声明的处理规则同 v2：
- `confirmed`：纳入交付物，附源引用
- `corrected`：纳入修正版
- `no_data`：标注「无证据支持」，不用训练知识填补
- `source_conflict`：呈现双方
- `contradicted`：排除或标注为已证伪

### Deliverable

交付物 = 正文 + Claim Ledger 附录 + Coverage Matrix 摘要。
尾部标注"经过脑暴/核查"。

Output: `06-judgment.md` + `07-deliverable.*`

---

## Source Handling

| Source type | Action |
|-------------|--------|
| PDF, audio recording | Upload directly to NLM via `source_add(source_type=file)` |
| Web URL | Add via `source_add(source_type=url)` |
| Local text / markdown | Add via `source_add(source_type=text)` |
| Crawled fragments | Merge into structured document, then upload as single file |
| Sensitive material | Ask user for explicit permission before uploading |

---

## Three Modes

### Lightweight Mode

**When:** Low-impact + simple sources (1-2 docs, <5 questions, no high-stakes).

简化：
- Step 0+1 合并：契约 + 快速搜索，Coverage Matrix 内联
- Step 3 脑暴跳过
- Step 4 的 5问自检简化为 3 问
- Claim Ledger 内联
- 单文件产出

### Standard Mode

**When:** Default for most research tasks.

文件链：
- `01-brief.md`：契约 + 源
- `02-coverage.md`：Coverage Matrix
- `03-claims.md`：假设 + Claim Ledger
- `04-final.md`：综合 + 交付物

### Audit Mode

**When:** High-impact, complex sources, contradictions, external publication.

完整文件链：
- `00-config.md`
- `01-brief-and-sources.md`
- `02-coverage.md`：Coverage Matrix（持续更新）
- `03-hypotheses.md`
- `04-challenge.md`
- `05-evidence.md`
- `06-judgment.md`
- `07-deliverable.*`
- Claim Ledger 贯穿 03-06
- Standard Changelog 记录维度变更（可选）
