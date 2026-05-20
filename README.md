# zuoshi-kaopu

**Two actions for when it matters: brainstorm blind spots, verify against sources.**

[中文版](README.zh-CN.md)

## What It Does

This is not a research tool. It is two actions you can use anytime during your work.

**Brainstorm** ("脑暴"): When you feel your thinking might have blind spots, say
"brainstorm." A second AI model will challenge your ideas. It finds unstated
assumptions, logical gaps, and things you have not considered. It only asks hard
questions. It does not give you replacement solutions. You decide what to change.

For example:
- You wrote a business plan and the positioning feels off
- You built an analysis framework and worry you are following a template
- You are about to make a big decision and want to hear the other side

**Verify** ("质证"): When you said something and want to check if your source
materials actually support it, say "verify." NotebookLM will search your documents
and return the exact quote, the source location, and a confidence level. If there
is no evidence, it says "not found." It does not make things up.

For example:
- You cited a number from a report and want to confirm the original text
- You wrote a claim and want to know if your materials back it up
- A colleague stated a fact and you want to check the source

## Quick Start

### Claude Code

```bash
git clone https://github.com/Kewanvk/zuoshi-kaopu.git ~/zuoshi-kaopu
cd ~/zuoshi-kaopu && claude plugin add .
```

Then type `/zuoshi-kaopu` to run first-time setup (installs NotebookLM, configures
second model). After setup, just say "脑暴" or "质证" in any conversation.

### Codex CLI

```bash
git clone https://github.com/Kewanvk/zuoshi-kaopu.git ~/zuoshi-kaopu
mkdir -p ~/.codex/skills
cp -r ~/zuoshi-kaopu/skills/zuoshi-kaopu ~/.codex/skills/zuoshi-kaopu
```

Then type `/zuoshi-kaopu` to run first-time setup. After setup, just say
"脑暴" or "质证" in any conversation.

## Dependencies

| Dependency | Required | Purpose |
|-----------|----------|---------|
| NotebookLM MCP | Yes | Evidence engine for "verify." Checks claims against source text with exact quotes |
| Second LLM | No | Strengthens "brainstorm." Falls back to self-critique if unavailable |

NotebookLM is free with a Google account. Install:
```bash
pipx install notebooklm-mcp-cli
nlm login
nlm setup add <your-platform>
```

For the second model, you can use an API aggregator (SiliconFlow, OneAPI, OpenRouter),
a direct API key (Anthropic, Google, Moonshot), another CLI tool, or a local model.

## How Brainstorm Works

When you say "brainstorm," the skill sends your thinking to a second model with
a strict adversarial protocol:

1. Find blind spots and unstated assumptions
2. Identify logical gaps
3. Ask hard questions you have not considered
4. Classify each finding: logic risk / evidence risk / execution risk
5. **No replacement solutions. No praise. Only problems.**

You get back a list of challenges. You decide what to change.

## How Verify Works

When you say "verify," the skill queries NotebookLM and returns an evidence card:

```
Claim: [your statement]
Verdict: supported / partially supported / not found / contradicted
Evidence: [exact quote from source]
Citation: [document + location]
Confidence: direct / indirect / no_data / source_conflict
What this does NOT prove: [prevents over-interpretation]
```

If NotebookLM finds nothing, it says "not found." It does not fill gaps with
general knowledge.

## Limitations

- Verify works with sources you provide. It does not search the internet
- NotebookLM free tier allows ~50 queries/day
- Brainstorm catches blind spots but is not a substitute for domain expertise
- "Supported" means supported by your sources, not by all possible sources

## License

MIT
