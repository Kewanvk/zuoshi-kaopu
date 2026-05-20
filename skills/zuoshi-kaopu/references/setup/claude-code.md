# Setup: Claude Code

## 1. Install the Skill

```bash
# Clone the repo
git clone https://github.com/Kewanvk/zuoshi-kaopu.git ~/zuoshi-kaopu

# Register as Claude Code plugin
cd ~/zuoshi-kaopu
claude plugin add .
```

After installation, the skill is available via `/zuoshi-kaopu` in Claude Code.

## 2. Install NotebookLM MCP (Required)

NotebookLM is the evidence engine. The skill cannot run without it.

```bash
# Install the NotebookLM CLI
pipx install notebooklm-mcp-cli

# Authenticate with your Google account
nlm login

# Register the MCP server for Claude Code
nlm setup add claude-code

# Optional: install the NLM skill (provides basic NLM usage tips)
# Not required if you are using zuoshi-kaopu, which includes its own methodology
nlm skill install claude-code
```

### Verify installation

After setup, these NLM tools should be available in Claude Code:
- `notebook_create`
- `notebook_query`
- `source_add`
- `notebook_list`

You can verify by asking Claude Code: "List my NotebookLM notebooks."

### Troubleshooting

- **Authentication errors**: Run `nlm login` again
- **MCP not detected**: Restart Claude Code after running `nlm setup add`
- **Free tier limit**: Google accounts get ~50 NLM queries/day. For large
  projects, plan queries efficiently or continue the next day

## 3. Configure Second LLM (Optional)

A second LLM strengthens the adversarial challenge step (Step 3).

### Option A: Codex (if you have an OpenAI subscription)

Codex is available as a CLI tool. If installed, the skill can use `/codex consult`
for adversarial challenges.

```bash
# Install Codex CLI (requires Node.js)
npm install -g @openai/codex

# Authenticate
codex login
```

Note: `/codex consult` requires the gstack codex skill to be installed in
Claude Code. If you only have the Codex CLI, use `codex exec` directly.

### Option B: Gemini (if you have a Google AI Studio key)

If you have Gemini access via MCP, configure it as an alternative challenger.

### Option C: No second LLM

The skill will spawn a sub-agent with a contrarian prompt. This is less effective
than a separate model but still useful.

## Quick Start

Once setup is complete:

1. Open Claude Code in your project directory
2. Type `/zuoshi-kaopu`
3. Describe your research task
4. The skill will guide you through environment verification and the five-step workflow
