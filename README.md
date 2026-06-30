# vkskill

**Kewan's Codex workflows.**

[中文版](README.zh-CN.md)

## What It Is

`vkskill` is a small Codex skill set. The first module is `vkskill-proof`.

`vkskill-proof` helps with three jobs:

1. Find evidence
2. Challenge assumptions
3. Verify claims

There is also a full research mode that chains the three jobs.

## Install For Codex

```bash
git clone https://github.com/Kewanvk/vkskill.git ~/vkskill
cd ~/vkskill
./install-codex.sh
```

Restart Codex after install.

Then say one of these:

```text
vkskill
vkskill-proof
找证据
找漏洞
验证说法
研究 AI 搜索产品
```

The old `zuoshi-kaopu` and `做事靠谱` triggers still work as aliases.

## Skills

| Skill | Use it for |
|---|---|
| `vkskill` | Main entry. Routes to the right workflow. |
| `vkskill-proof` | Evidence workflow entry. Shows the three proof actions. |
| `vkskill-source` | Find sources, capture original text, and load sources into NotebookLM. |
| `vkskill-challenge` | Challenge an idea and find blind spots, assumptions, and logic gaps. |
| `vkskill-verify` | Verify a claim against source documents with NotebookLM quotes. |
| `vkskill-research` | Run the full research loop with sources, claims, challenge, and verification. |
| `zuoshi-kaopu` | Legacy alias for the old name. |

## Dependencies

| Dependency | Required | Purpose |
|---|---|---|
| NotebookLM MCP | Yes for verification | Evidence engine for source loading and claim checks |
| curl + textutil | Yes on macOS | First layer source capture |
| Second LLM or MiMo | Optional | Better adversarial challenge |
| Browser tool or Playwright | Optional | Fallback for JS-rendered sites |

NotebookLM setup:

```bash
pipx install notebooklm-mcp-cli
nlm login
nlm setup add codex
```

## What Each Action Does

### Find Evidence

Search the web, filter sources, capture full original text into `raw/`, and load the sources into NotebookLM.

### Challenge Assumptions

Send your thinking through an adversarial pass. The output is a list of weak assumptions, logic gaps, and evidence risks.

### Verify Claims

Ask NotebookLM whether source documents support a specific claim. The output is an evidence card with quote, source, verdict, confidence, and limits.

### Research

Run the full loop:

```text
Scope -> sources -> claim ledger -> challenge -> verification -> final judgment
```

## Limits

- Verification only checks the sources you provide.
- Some sites block automated capture.
- NotebookLM quotes count as evidence. NotebookLM summaries still need judgment.

## License

MIT
