# zuoshi-kaopu

**在"幻觉的聪明"和"愚笨的准确"之间，找到平衡。**

每条结论都能查到来源、验证过程和置信度。

[English](README.md)

## 它产出什么

大多数 AI 研究工具给你一份漂亮的报告配上引用。引用可以是装饰性的。这个 skill 先产出**证据轨迹**，再出报告。

核心产出物是 **Claim Ledger（论断账本）**：

```
| ID | 结论                    | 状态         | 原文引用                  | 来源           | 置信度     |
|----|------------------------|-------------|--------------------------|---------------|-----------|
| C1 | 营收超过 1000 万         | confirmed   | "总营收达到 1030 万"       | 年报 p.12     | direct    |
| C2 | 2015 年成立             | corrected   | "2016 年 3 月注册成立"     | 工商登记       | direct    |
| C3 | 细分市场领导者           | no_data     |                          |               |           |
| C4 | 与 X 公司有合作关系       | source_conflict| 两份材料说法矛盾           | 新闻 + 年报    | indirect  |
```

`no_data` 的结论不会被悄悄删掉。它们留在那里。这就是重点。

## 工作原理

LLM 聪明但会幻觉。NotebookLM 准确但只能看到你给它的东西。这个 skill 让它们配合：

1. **定题 + 灌源**：定义研究问题，把信息源灌进 NotebookLM
2. **出假设**：LLM 读材料、出假设、开始建 Claim Ledger
3. **对抗性挑战**（自动触发）：第二个 LLM 或 sub-agent 挑战假设
4. **质证**：NotebookLM 逐条验证每个假设，用原文引用
5. **最终判断 + 交付**：基于已验证的结论出交付物 + Claim Ledger 附录

## 什么时候用

你的产出会被别人当真用，且有信息源需要处理：

- 研究报告、行业分析
- 文档/报告中的事实核查
- 分析采访录音或逐字稿
- 竞品/对标分析
- 课程作业、论文
- 任何"编的不行"的场景

## 什么时候不用

- 纯创意工作（没有"对不对"只有"好不好"）
- 脑暴探索阶段（幻觉反而是优势）
- 纯执行任务（部署、配置、搭建）

## 三种模式

| 模式 | 触发条件 | 产出 |
|------|---------|------|
| 轻量 | 结论影响小 + 源简单 | 单个文件，行内引用 |
| 标准 | 默认 | 3 个文件（简报、论断、终稿） |
| 审计 | 结论影响大 或 源复杂/冲突 | 完整文件链 + 完整 Claim Ledger |

Skill 根据影响程度和源复杂度自动选择模式。

## 快速开始

### Claude Code

```bash
git clone https://github.com/Kewanvk/zuoshi-kaopu.git ~/zuoshi-kaopu
cd ~/zuoshi-kaopu && claude plugin add .

# 安装 NotebookLM MCP（必须）
pipx install notebooklm-mcp-cli
nlm login
nlm setup add claude-code
nlm skill install claude-code
```

然后在 Claude Code 中输入 `/zuoshi-kaopu`。

### Codex CLI

```bash
git clone https://github.com/Kewanvk/zuoshi-kaopu.git ~/zuoshi-kaopu
mkdir -p ~/.codex/skills
cp -r ~/zuoshi-kaopu/skills/zuoshi-kaopu ~/.codex/skills/zuoshi-kaopu

# 安装 NotebookLM MCP（必须）
pipx install notebooklm-mcp-cli
nlm login
nlm setup add codex
```

然后在 Codex 中输入 `/zuoshi-kaopu`。

详细的平台安装指南见 `skills/zuoshi-kaopu/references/setup/`。

## 依赖

| 依赖 | 是否必须 | 用途 |
|-----|---------|------|
| NotebookLM MCP | 是 | 证据引擎。提供基于原文的质证能力 |
| 第二个 LLM（Codex/Claude/Gemini） | 否 | 对抗性挑战。没有则用 sub-agent 替代 |

## 局限性

- 不会主动搜索互联网。只处理你提供的信息源。如果你给它 URL 或要求它爬取特定页面，它会把这些作为信息源处理
- NotebookLM 免费版每天约 50 次查询。大型项目可能需要多个 session
- 对抗性挑战能发现盲点，但不能替代领域专业知识
- "已验证"指的是对照已提供的信息源验证，不是对照所有可能的信息源
- 无法验证需要视觉判断的非文本内容

## 参考文件

| 文件 | 用途 |
|------|------|
| `references/methodology.md` | 完整的五步工作流 |
| `references/evidence-rules.md` | 证据处理规则 |
| `references/error-patterns.md` | 8 条常见错误模式 |
| `references/source-grading.md` | 来源可靠性分级（A/B/C/D/X） |
| `references/claim-ledger-template.md` | Claim Ledger 格式规范 |

## 许可

MIT
