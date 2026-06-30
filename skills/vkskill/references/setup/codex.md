# Setup: Codex CLI

## 1. Install the Skill

```bash
# Clone the repo
git clone https://github.com/Kewanvk/vkskill.git ~/vkskill

# Link skill to the Codex skills directory
mkdir -p ~/.agents/skills
ln -s ~/vkskill/skills/vkskill ~/.agents/skills/vkskill
ln -s ~/vkskill/skills/zuoshi-kaopu ~/.agents/skills/zuoshi-kaopu
```

After installation, restart Codex to load the skill. To use it, tell Codex:
"Use the vkskill skill to [your research task]."

Some older Codex setups use `~/.codex/skills`. If the skill does not appear
after restart, copy or link the same folder there.

## 2. Install NotebookLM MCP (Required)

NotebookLM is the evidence engine. The skill cannot run without it.

```bash
# Install the NotebookLM CLI
pipx install notebooklm-mcp-cli

# Authenticate with your Google account
nlm login

# Register the MCP server for Codex
nlm setup add codex
```

### Verify installation

After setup, check that the MCP server is registered:

```bash
codex mcp list
```

You should see NotebookLM in the list. The following tools should be available:
- `notebook_create`
- `notebook_query`
- `source_add`
- `notebook_list`

### Troubleshooting

- **Authentication errors**: Run `nlm login` again
- **MCP not detected**: Restart Codex first. Then run `codex mcp list` to verify
  registration. If missing, re-run `nlm setup add codex`
- **Free tier limit**: Google accounts get ~50 NLM queries/day

## 3. Configure Second LLM (Optional)

A second LLM strengthens the adversarial challenge step (Step 3).

### Option A: Claude (if you have an Anthropic API key)

If you have Claude access, you can configure it as an adversarial challenger
via MCP or direct API calls.

### Option B: Gemini (if you have a Google AI Studio key)

Configure Gemini as an alternative challenger via MCP.

### Option C: No second LLM

The skill will spawn a sub-agent with a contrarian prompt as fallback.

## Quick Start

Once setup is complete:

1. Open Codex in your project directory
2. Tell Codex: "Use the vkskill skill to [your research task]"
3. The skill will guide you through environment verification and the five-step workflow
