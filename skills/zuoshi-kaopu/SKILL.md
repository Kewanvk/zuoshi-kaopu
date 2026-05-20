---
name: zuoshi-kaopu
description: >
  Use this skill when the user needs to research, analyze, or verify information
  from documents, reports, recordings, or web sources. Triggers include: "research
  this", "verify these claims", "analyze this report", "fact-check", "extract data
  from these files", "cross-verify", "write a research report", or any task where
  conclusions must be traceable to source evidence. Produces a Claim Ledger where
  every conclusion has a source, verification status, and confidence level.
version: 1.0.0
---

# zuoshi-kaopu (做事靠谱)

一套让 AI 研究产出可信的方法论。组合 LLM 的泛化能力和 NotebookLM 的质证准确度，
通过 Claim Ledger（论断账本）让每条结论可追溯。

**核心原则：** LLM 是假设引擎（聪明但会幻觉）。NotebookLM 是证据引擎（准确但只看
原文）。这个 skill 让它们配合，产出你能信任的结论。

**语言规则：与用户使用相同的语言交流。用户用中文提问就用中文回复，用英文就用英文。
默认中文。**

## Step 0: 环境配置（仅首次运行）

开始研究前，先确认用户的工具可用性。

### 必须：NotebookLM MCP

NotebookLM 是证据引擎。没有它，这个 skill 无法运行。

问用户：**"你安装了 NotebookLM MCP 吗？"**

- 如果有：验证 `notebook_list` 等 NLM 工具是否可用
- 如果没有：根据平台引导安装。读取 `references/setup/claude-code.md`
  或 `references/setup/codex.md` 中的平台安装指引

### 可选：第二个 LLM（对抗性挑战）

第二个 LLM 通过对抗性挑战来加强假设检验。

问用户：**"你有没有其他模型可以用？（比如 Codex、Claude、Gemini）"**

- 如果有：配置为对抗方（通过 MCP 或 `/codex consult`）
- 如果没有：用 sub-agent 配合反向 prompt 作为替代

In Audit mode, record the configuration in the project's `00-config.md`.
Standard and Lightweight modes skip this file.

## Five-Step Workflow

Read `references/methodology.md` for full details. The file names below are for
Audit mode. Standard and Lightweight modes use fewer, consolidated files (see
Three Modes below). Summary:

### Step 1: Research Brief + Source Loading

Define the research question, scope, risk level, and deliverable type. Then load
all source materials into NotebookLM.

Output: `01-brief-and-sources.md`

### Step 2: Hypothesis Generation

The LLM reads source materials and forms hypotheses, analysis frameworks, or
question lists. Begin building the Claim Ledger with status = unverified.

Output: `02-hypotheses.md` (includes initial Claim Ledger)

### Step 3: Adversarial Challenge (rule-triggered)

**Triggers automatically when any of these apply:**
- Research involves recommendations, rankings, or comparisons
- Research involves factual judgments about people or companies
- Research involves money, legal, or reputation decisions
- Source materials contain contradictory information

When none apply, skip to Step 4.

Send hypotheses to the second LLM (or sub-agent). Accept problems it identifies;
reject replacement solutions by default (regenerate from context instead).

Output: `03-challenge.md`

### Step 4: Evidence Verification

Query NotebookLM with specific, verifiable questions derived from each hypothesis.
Update the Claim Ledger with evidence.

For each claim, record four fields:
- **Conclusion**: what the evidence shows
- **Source quote**: exact passage from NLM
- **Source**: document name, page, or URL
- **Confidence**: `direct` / `indirect` / `no_data` / `source_conflict`

Extraction and verification must be separate passes. NLM's own synthesis is not
evidence; only the source text it quotes is.

Output: `04-evidence.md` (updated Claim Ledger)

### Step 5: Final Judgment + Delivery

Review the Claim Ledger. If verification contradicts key hypotheses, loop back
to Step 2 (revision trigger).

Otherwise, produce the deliverable with the Claim Ledger as appendix.

Output: `05-judgment.md` + `06-deliverable.*`

## Three Modes

| Mode | Trigger | Output files |
|------|---------|-------------|
| Lightweight | Low-impact conclusions + simple sources | `final.md` with inline citations |
| Standard | Default | `01-brief.md` + `02-claims.md` + `03-final.md` |
| Audit | High-impact conclusions OR complex/conflicting sources | Full file chain (00-06) + Claim Ledger |

**Trigger matrix:**

|  | Low-impact conclusions | High-impact conclusions |
|---|---|---|
| Simple sources | Lightweight | Standard |
| Complex / conflicting sources | Standard | Audit |

**High-impact** = involves money, legal, personnel, reputation decisions; will be
published externally; involves factual claims about people or companies.

## Quality Checklist (run before delivery)

Four checks. If any fails, fix before delivering.

1. **Does every key conclusion have a source quote from NLM?**
2. **Did any data come from training knowledge instead of sources?** (If so, mark
   it explicitly or remove it)
3. **Did verification target the most error-prone claims, or just the easy ones?**
4. **Are uncertain items marked with their confidence level?**

## Reference Files

- `references/methodology.md` : Full five-step workflow with file specs
- `references/evidence-rules.md` : Evidence discipline rules
- `references/error-patterns.md` : 8 common error patterns with examples
- `references/source-grading.md` : Source grading system (A/B/C/D/X)
- `references/claim-ledger-template.md` : Claim Ledger format and field definitions
- `references/setup/claude-code.md` : Setup guide for Claude Code users
- `references/setup/codex.md` : Setup guide for Codex users
