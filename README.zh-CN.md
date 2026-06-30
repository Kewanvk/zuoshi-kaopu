# vkskill

**可万的 Codex 工作流。**

[English](README.md)

## 它是什么

`vkskill` 是一组 Codex skill。第一组功能叫 `vkskill-proof`。

`vkskill-proof` 做三件事：

1. 找证据
2. 找漏洞
3. 验证说法

它还有一个完整研究模式，可以把这三件事串起来。

## Codex 安装

```bash
git clone https://github.com/Kewanvk/vkskill.git ~/vkskill
cd ~/vkskill
./install-codex.sh
```

安装后重启 Codex。

然后可以直接说：

```text
vkskill
vkskill-proof
找证据
找漏洞
验证说法
研究 AI 搜索产品
```

旧触发词 `zuoshi-kaopu` 和 `做事靠谱` 仍然可用。

## Skill 列表

| Skill | 用途 |
|---|---|
| `vkskill` | 总入口。判断你要用哪个工作流。 |
| `vkskill-proof` | 证据工作流入口。展示三个动作。 |
| `vkskill-source` | 找材料，保存原文，灌进 NotebookLM。 |
| `vkskill-challenge` | 找漏洞，拆假设，看逻辑风险。 |
| `vkskill-verify` | 用 NotebookLM 验证某个说法有没有原文支撑。 |
| `vkskill-research` | 跑完整研究流程。 |
| `zuoshi-kaopu` | 旧名字兼容入口。 |

## 依赖

| 依赖 | 是否必须 | 用途 |
|---|---|---|
| NotebookLM MCP | 质证必须 | 灌源和验证说法 |
| curl + textutil | macOS 必须 | 第一层网页原文抓取 |
| 第二个模型或 MiMo | 可选 | 提高脑暴质量 |
| 浏览器工具或 Playwright | 可选 | 处理 JS 渲染网页 |

NotebookLM 安装：

```bash
pipx install notebooklm-mcp-cli
nlm login
nlm setup add codex
```

## 三个动作

### 找证据

搜索网页，筛选来源，保存完整原文到 `raw/`，再把来源灌进 NotebookLM。

### 找漏洞

把你的想法过一遍对抗检查。输出盲区、隐藏假设、逻辑漏洞和证据风险。

### 验证说法

用 NotebookLM 查源材料是否支持某个具体说法。输出证据卡，包括原文、来源、结论、置信度和不能证明什么。

### 研究

完整流程：

```text
定范围 -> 找证据 -> 论断账本 -> 找漏洞 -> 质证 -> 最终判断
```

## 边界

- 质证只检查你提供的材料。
- 有些网站会挡住自动抓取。
- NotebookLM 引用的原文才算证据。NotebookLM 自己的总结仍然要判断。

## 许可

MIT
