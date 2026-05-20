# zuoshi-kaopu

**关键时刻两个动作：脑暴找漏洞，质证查原文。**

[English](README.md)

## 它是什么

这不是一个研究工具。它是你工作中随时可以拉出来的两个动作。

**脑暴**：你觉得自己的想法可能有盲区时，说"脑暴"。另一个 AI 模型会专门挑战你的想法：
找你没说出来的假设、逻辑漏洞、你没考虑到的问题。它只许提问，不给替代方案。你自己决定改不改。

比如：
- 你写了一个商业方案，觉得定位不够锐利
- 你做了一个分析，怀疑自己在套模板
- 你要做一个重要决策，想听听反面意见

**质证**：你说了一个结论，想确认源材料是不是真的支持它，说"质证"。NotebookLM 会去查你的
源材料原文，告诉你：有没有证据、证据原文是什么、这个证据能证明什么、不能证明什么。
如果没有证据，直接说"没有"，不会编。

比如：
- 你引用了一份报告里的数据，想确认原文是不是这么说的
- 你写了一个论点，想知道材料里有没有支撑
- 同事说了一个事实，你想查一下出处

## 快速开始

### Claude Code

```bash
git clone https://github.com/Kewanvk/zuoshi-kaopu.git ~/zuoshi-kaopu
cd ~/zuoshi-kaopu && claude plugin add .
```

输入 `/zuoshi-kaopu` 完成首次配置（安装 NotebookLM、配置第二模型）。
配置完成后，在任何对话中说"脑暴"或"质证"即可。

### Codex CLI

```bash
git clone https://github.com/Kewanvk/zuoshi-kaopu.git ~/zuoshi-kaopu
mkdir -p ~/.codex/skills
cp -r ~/zuoshi-kaopu/skills/zuoshi-kaopu ~/.codex/skills/zuoshi-kaopu
```

输入 `/zuoshi-kaopu` 完成首次配置。之后在任何对话中说"脑暴"或"质证"即可。

## 依赖

| 依赖 | 是否必须 | 用途 |
|-----|---------|------|
| NotebookLM MCP | 是 | 质证的证据引擎。对照源材料原文验证，返回精确引用 |
| 第二个 LLM | 否 | 加强脑暴效果。没有的话用自我对抗模式替代 |

NotebookLM 免费，用 Google 账号就行：
```bash
pipx install notebooklm-mcp-cli
nlm login
nlm setup add <你的平台>
```

第二个模型可以用 API 中转站（硅基流动、OneAPI、OpenRouter）、直接 API（Anthropic、Google、
Moonshot）、另一个 CLI 工具、或本地模型。

## 脑暴怎么工作的

说"脑暴"时，skill 把你的想法发给第二个模型，附带严格的对抗协议：

1. 找盲区和未说出的假设
2. 找逻辑漏洞
3. 提出你没考虑到的尖锐问题
4. 每个发现分类：逻辑风险 / 证据风险 / 执行风险
5. **不给替代方案。不夸你。只找问题。**

你拿到一份挑战清单。你自己决定怎么改。

## 质证怎么工作的

说"质证"时，skill 查询 NotebookLM，返回一张证据卡：

```
论断：[你说的话]
结论：有支撑 / 部分支撑 / 未找到 / 矛盾
证据：[源材料原文引用]
出处：[文档 + 位置]
置信度：直接 / 间接 / 无数据 / 源冲突
这个证据不能证明：[防止过度推断]
```

NotebookLM 找不到就说"未找到"。不会用通用知识填坑。

## 局限性

- 质证只能查你提供的材料，不会搜索互联网
- NotebookLM 免费版每天约 50 次查询
- 脑暴能发现盲点，但不能替代领域专业知识
- "有支撑"指的是你的材料支撑，不是所有可能的材料

## 许可

MIT
