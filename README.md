# zuoshi-kaopu

**Three actions for when it matters: gather sources, brainstorm blind spots, verify against evidence.**

[中文版](README.zh-CN.md)

## What It Does

Three actions you can use anytime during your work. Plus a full research mode
that chains them together.

**Gather** ("搜证"): When you need materials from the web, say "gather sources."
It searches, quickly filters for relevance, then captures the full original text
of high-value sources. Saves everything locally and loads it into NotebookLM
so you can verify claims later.

**Brainstorm** ("脑暴"): When you feel your thinking might have blind spots, say
"brainstorm." A second AI model challenges your ideas: finds unstated assumptions,
logical gaps, and things you have not considered. It only asks hard questions.
No replacement solutions. You decide what to change.

**Verify** ("质证"): When you said something and want to check if your source
materials actually support it, say "verify." NotebookLM searches your documents
and returns the exact quote, the source location, and a confidence level. If
there is no evidence, it says "not found." It does not make things up.

**Research** ("研究 + topic"): Runs the full flow. Defines the research scope,
gathers sources, forms hypotheses, challenges them, verifies claims, and
delivers a report with a complete evidence trail.

## Quick Start

### Claude Code

```bash
git clone https://github.com/Kewanvk/zuoshi-kaopu.git ~/zuoshi-kaopu
cd ~/zuoshi-kaopu && claude plugin add .
```

Then type `/zuoshi-kaopu` to run first-time setup (installs NotebookLM,
configures second model). After setup, just say "搜证", "脑暴", or "质证"
in any conversation.

### Codex CLI

```bash
git clone https://github.com/Kewanvk/zuoshi-kaopu.git ~/zuoshi-kaopu
mkdir -p ~/.agents/skills
ln -s ~/zuoshi-kaopu/skills/zuoshi-kaopu ~/.agents/skills/zuoshi-kaopu
```

Then restart Codex and tell it `zuoshi-kaopu` or `做事靠谱` to run first-time
setup.

Older Codex setups may use `~/.codex/skills` instead of `~/.agents/skills`.
If Codex does not detect the skill after restart, copy or link the same
`skills/zuoshi-kaopu` folder there.

## How Each Action Works

### Gather ("搜证")

```
WebSearch → URL list
    ↓
WebFetch quick scan → filter by relevance (AI summary, fast)
    ↓
curl / Playwright → capture full original text (no AI processing)
    ↓
Save to raw/ locally + load into NotebookLM
```

Why two steps? WebFetch returns AI summaries that lose ~93% of content. That is
fine for judging "is this relevant?" but not for evidence. The deep capture step
gets the real text.

If NotebookLM cannot load a URL (common with Chinese sites), the locally saved
file is uploaded as a fallback.

### Brainstorm ("脑暴")

Your thinking goes to a second AI model with a strict adversarial protocol:

1. Find blind spots and unstated assumptions
2. Identify logical gaps
3. Ask hard questions you have not considered
4. Classify each finding: logic risk / evidence risk / execution risk
5. **No replacement solutions. No praise. Only problems.**

You get back a list of challenges. You decide what to change.

### Verify ("质证")

Claims are checked against NotebookLM with a three-layer verification:

1. **Link works?** Is the source URL still accessible?
2. **Content relevant?** Does the page actually discuss this topic?
3. **Fact supported?** Does the text actually support this specific claim?

Each claim gets an evidence card:

```
Claim:      [your statement]
Verdict:    supported / not found / contradicted
Evidence:   [exact quote from source]
Citation:   [document + location]
Confidence: direct / indirect / no_data / source_conflict
```

If NotebookLM finds nothing, it says "not found." No gap-filling with
general knowledge.

### Research ("研究 + topic")

The full flow chains all three actions:

```
Contract → Gather + Coverage Matrix → Hypotheses → Brainstorm + Verify → Deliver
```

Two questions set the scope: "understand or decide?" and "quick overview or
independent judgment?" This determines the mode (Lightweight / Standard / Audit)
and how thorough each step is.

## Dependencies

| Dependency | Required | Purpose |
|-----------|----------|---------|
| NotebookLM MCP | Yes | Evidence engine for verify and source loading |
| Second LLM | No | Strengthens brainstorm. Falls back to self-critique |
| curl + textutil | Yes (macOS) | Source capture Layer 1. Built-in, zero setup |
| Playwright or browser tool | No | Source capture Layer 2. For JS-rendered sites |

NotebookLM is free with a Google account:
```bash
pipx install notebooklm-mcp-cli
nlm login
nlm setup add <your-platform>
```

## Limitations

- Verify works with sources you provide, not the entire internet
- Some sites block all automated access (captcha, login walls). These are
  logged for manual retrieval
- Brainstorm catches blind spots but is not a substitute for domain expertise
- "Supported" means supported by your sources, not by all possible sources

## License

MIT
