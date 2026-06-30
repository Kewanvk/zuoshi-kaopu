# 人类成熟领域的循证 / 考证 / 情报方法论调研

**目的**：为「用源材料质证 AI 结论」的工作流(现有：A/B/C/D/X 信源分级 + Claim Ledger 声明账本 + 置信度字段 + 交叉验证规则)寻找可迁移的精细机制。

**方法论说明**：英文搜索 + 追一手源。CIA Tradecraft Primer 直接读了官方 PDF 原文(cia.gov 2009 版),GRADE 读了 consensus 论文,Admiralty Code / ACH / 历史考证读了维基方法论条目并追定义,PRISMA 读了官网。每条方法标注来源等级。下面凡是引号内的英文都是从原始材料逐字抄录。

---

## 一、情报分析：Admiralty Code（NATO 6×6 信源评估系统）★ 重点深挖

**来源领域**：军事 / 情报(NATO STANAG 2511，可追溯到英国皇家海军)
**来源链接**：
- 维基(方法论条目，定义逐字源)：https://en.wikipedia.org/wiki/Admiralty_code
- 实践批评：https://www.matthewwold.net/post/intelligence-grading-why-the-admiralty-code-matters
- CTI 行业应用：https://kravensecurity.com/source-reliability-and-information-credibility/

**核心机制**：把一条情报拆成两个**互相独立**的维度打分，给出一个两字符代码(如 `B2`)。
- 维度一 = 信源可靠性(Source Reliability)，字母 A–F：
  - A = "Completely reliable: No doubt of authenticity, trustworthiness, or competency; has a history of complete reliability"
  - B = "Usually reliable: Minor doubt... has a history of valid information most of the time"
  - C = "Fairly reliable: Doubt... but has provided valid information in the past"
  - D = "Not usually reliable: Significant doubt... but has provided valid information in the past"
  - E = "Unreliable: Lacking in authenticity, trustworthiness, and competency; history of invalid information"
  - F = "Reliability cannot be judged: No basis exists for evaluating the reliability of the source"
- 维度二 = 信息可信度(Information Credibility)，数字 1–6：
  - 1 = "Confirmed by other sources: Confirmed by other independent sources; logical in itself; consistent with other information on the subject"
  - 2 = "Probably True: Not confirmed; logical in itself; consistent with other information"
  - 3 = "Possibly True: Not confirmed; reasonably logical; agrees with some other information"
  - 4 = "Doubtful: Not confirmed; possible but not logical; no other information"
  - 5 = "Improbable: Not confirmed; not logical in itself; contradicted by other information"
  - 6 = "Truth cannot be judged: No basis exists for evaluating the validity of the information"

**关键原则(逐字)**：两个维度必须分开评，互不污染——
> "Each descriptor is considered in isolation to ensure that the reliability of the source does not influence the assessed accuracy of the report."

通俗说：一个高可靠信源(A)也可能这次报了一条无法证实的内容(A5)；一个平时不可靠的信源(D)也可能这次说对了被多源证实(D1)。"A reliable source can still report inaccurate details, and an unreliable source can sometimes be right."

**已知局限(实践者总结)**：
- 主观性——分级取决于分析员判断，不同人不同组织会打出不一样的分，需要训练拉齐标准。
- 模型不捕捉信源动机、时效、偏见这些细节。
- 有人为了制造紧迫感故意把分打高，长期会让系统失效。
- 数字 1 "confirmed by independent sources" 隐含一个陷阱：必须是**真正独立**的源。这正是后面要讲的「循环报告(circular reporting)」问题——同一个原始源被转述几遍，看起来像多源印证，其实是一个源。

**对我们工作流的潜在借鉴点(最重要的一条)**：
我们现在的 A/B/C/D/X 是**单维**的——它把"这个源可不可信"和"这条具体信息可不可信"压成了一个字母。Admiralty 把它们拆成两维。迁移过来：
- 现有 A/B/C/D/X 对应 Admiralty 的**字母维(信源可靠性)**——它评的是源的"出身"。
- 我们的 Claim Ledger 里的 confidence 字段(direct/indirect/no_data/source_conflict)其实在评**数字维(信息可信度)**——但还没系统化成 1–6 那样的「被几个独立源证实」的梯度。
- 升级方案：每条 Claim 打一个**双字符码**，比如 `A2`(官方一手文件，但这条具体说法未被第二个源印证，只是逻辑自洽)、`D1`(新闻二手源，但被三个独立源交叉确认)。`D1` 的可信度其实高于 `A4`。这恰好能解决 source-grading.md 里已经写到但没工具化的那句话："A company's annual report is a good source for revenue figures but a biased source for competitive positioning"——年报是 A 级源，但它谈自己竞争优势那条 claim 应该打成 `A4` 或 `A5`(源可靠但这条内容存疑)。

---

## 二、医学循证：GRADE 证据质量分级 ★ 重点深挖

**来源领域**：循证医学 / 系统综述(GRADE Working Group)
**来源链接**：
- consensus 论文(定义逐字源)：https://pmc.ncbi.nlm.nih.gov/articles/PMC2335261/
- 官网 + Handbook：https://www.gradeworkinggroup.org/ (详细定义在 book.gradepro.org)
- 方法学原文：https://www.jclinepi.com/article/S0895-4356(10)00332-X/fulltext

**核心机制**：GRADE 把一**整批证据**(不是单篇研究)按结局(per outcome)分四级，关键创新是「起始分 + 升降级因素」的动态打分，而不是静态贴标签。
- 四级定义(逐字，注意它定义的是"未来研究改变结论的可能性"，本质是 meta 层面的稳定性)：
  - High = "Further research is very unlikely to change our confidence in the estimate of effect"
  - Moderate = "Further research is likely to have an important impact on our confidence... and may change the estimate"
  - Low = "Further research is very likely to have an important impact... and is likely to change the estimate"
  - Very Low = "Any estimate of effect is very uncertain"
- 起始分：随机对照试验起评 High，观察性研究起评 Low。
- **五个降级因素**(每个可降一到两级)：
  1. Risk of bias / study limitations — 研究设计有方法学缺陷。
  2. Inconsistency — 多个研究结论互相打架。
  3. Indirectness — 证据不是直接针对你的问题(用了替代指标、人群不对、间接对比)。
  4. Imprecision — 样本太小 / 置信区间太宽，量级不确定。
  5. Publication bias / reporting bias — 只有正面结果被发表，整体图景被扭曲。
- **三个升级因素**(只用于观察性研究)：
  1. Large magnitude of effect — 效应特别大(例：髋关节置换治重度骨关节炎)。
  2. Dose-response gradient — 剂量越大效果越强，暗示因果。
  3. Plausible confounding would reduce the effect — "all plausible biases would decrease the magnitude of an apparent treatment effect"，即所有可能的偏倚都只会让效果显得更小，那观察到的效果反而更可信。

**对我们工作流的潜在借鉴点**：
- **动态打分取代静态标签**：我们的 confidence 现在是离散四档(direct/indirect/no_data/conflict)。GRADE 的「起始分 + 因素升降」更细。可以给 Claim Ledger 加一个**升降级理由列**：这条 claim 起评 confirmed，但因为只有一个源(imprecision 类比)降一级；或者起评 indirect，但三个独立源 + 逻辑自洽 + 时间上越接近事件越一致(类比 dose-response)升一级。
- **indirectness 这一条直接能用**：AI 给的很多"结论"其实是 indirect evidence——源里没直接说，是 AI 从相关段落推的。我们的 `indirect` 标签已经在抓这个,但 GRADE 提醒可以再细分 indirectness 的子类型(替代指标 / 人群不对 / 间接推断)。
- **「所有偏倚都只会削弱效果，那效果反而可信」这个升级逻辑很妙**：迁移到质证——如果一条 claim 的所有已知偏倚方向都是让它"显得更弱"(比如自我声明里反而自黑的部分)，那它可信度应该升级，而不是因为是自我声明就降级。source-grading.md 里"self-declarations about own strengths carry bias"是对的，但反过来 self-declarations about own weaknesses 应该升可信度。
- **per-outcome / per-claim 而非 per-source**：GRADE 强调质量是对"一批证据针对某个结局"评的。这印证我们 source-grading.md 已有的原则"Final reliability is assessed at the claim level, not the source level"——GRADE 给了它一套成熟的操作框架。

---

## 三、情报分析：Analysis of Competing Hypotheses（ACH，Richards Heuer）★ 重点深挖

**来源领域**：CIA 情报分析(Richards Heuer, *Psychology of Intelligence Analysis*, 1999)
**来源链接**：
- CIA Tradecraft Primer 官方 PDF(逐字源，含完整矩阵实例)：https://www.cia.gov/resources/csi/static/Tradecraft-Primer-apr09.pdf
- 维基(七步法)：https://en.wikipedia.org/wiki/Analysis_of_competing_hypotheses
- Heuer 原文：https://pherson.org/wp-content/uploads/2013/06/Improving-Intelligence-Analysis-with-ACH.pdf

**核心机制(逐字定义)**：
> "Identification of alternative explanations (hypotheses) and evaluation of all evidence that will **disconfirm rather than confirm** hypotheses."

这是 ACH 的灵魂：**不去找支持你偏好假设的证据，而是去找能推翻每个假设的证据**。Heuer 的科学方法论根基——最可能的假设是「反证最少的那个」，不是「支持证据最多的那个」("The most probable hypothesis is the one with the least evidence against it, not the one with the most evidence for it.")。

**矩阵机制(从 CIA 原文实例还原)**：
- 假设排成列(横轴)，证据排成行(纵轴)。
- 每个格子标记这条证据对这个假设是 **C**(consistent 一致)/ **I**(inconsistent 不一致)/ **N**(neutral 中立/不适用)。
- **关键操作是"横着读证据，不是竖着读假设"**："examine it against all possible hypotheses... working across evidence rather than down hypotheses"。一条一条证据,看它能区分开哪些假设。
- **诊断价值(diagnosticity)**：一条证据如果对所有假设都 consistent，它毫无诊断价值(无法区分)；只对一个假设 inconsistent 的证据，诊断价值最高。CIA 原文脚注："The 'diagnostic value' of the evidence will emerge as analysts determine whether a piece of evidence is found to be consistent with only one hypothesis, or could support more than one or indeed all hypotheses. In the latter case, the evidence can be judged as unimportant to determining which hypothesis is more likely correct."
- **算分**：给每个假设算 Inconsistency Score(数 I 的数量/加权)，分数(负的)绝对值最大的假设最先被淘汰。CIA 的东京沙林毒气案实例里，四个假设的 Inconsistency Score 是 -1.0 / -1.0 / -2.0 / -3.0，分数越负的越不可能。
- **敏感性分析**："Analyze how sensitive the ACH results are to a few critical items of evidence; should those pieces prove to be wrong, misleading, or subject to deception, how would it impact an explanation's validity?"
- **缺失证据也是证据**："Ask what evidence is not being seen but would be expected for a given hypothesis to be true. Is denial and deception a possibility?" ——这是 ACH 处理"狗没叫"(本该出现却没出现的证据)的机制。

**对我们工作流的潜在借鉴点(我认为最值得抄的逻辑)**：
- **从"找证据支持结论"翻转成"找证据推翻结论"**。我们现在的 Claim Ledger 流程是：提假设 → 问 NLM"这是真的吗，证据在哪"。这本质还是在**找支持**。ACH 教的是：对每条 claim，应该主动问 NLM"**有没有任何源材料和这条 claim 矛盾**"。evidence-rules.md 里的对抗步骤(Step 3 Adversarial)思路对，但可以更系统：把竞争假设并排,逐条证据横着扫,标 C/I/N。
- **诊断价值概念可以直接进 Claim Ledger**：一条证据如果"支持所有可能的解释",它其实没用。现在我们没有字段记录一条证据的「区分力」。可以加一个 diagnosticity 标记——这条 source quote 是只支持当前 claim，还是对竞争解释也一样成立。后者要降权。
- **多假设并列对抗 AI 的"第一个看起来对的答案"**：CIA 原文点破 AI 也会犯的错——"Analysts often are susceptible to being unduly influenced by a first impression... a single explanation that seems to fit well enough." LLM 的高置信度幻觉就是这个。ACH 强制列出所有合理替代解释,给每个"equal treatment or weight",防止过早收敛。
- **缺失证据检查**：问"如果这条 claim 为真，源材料里本该出现什么但没出现?" 这比单纯的 no_data 更主动——no_data 是被动发现没有，ACH 是主动预测「本该有」然后去找缺口。

---

## 四、情报分析：CIA Structured Analytic Techniques（结构化分析技术）

**来源领域**：CIA(*A Tradecraft Primer*, 2009)
**来源链接**：官方 PDF https://www.cia.gov/resources/csi/static/Tradecraft-Primer-apr09.pdf

CIA 把技术分三类：诊断型(diagnostic)、对抗型(contrarian)、想象型(imaginative)。除了上面的 ACH，几个直接相关的：

### 4a. Quality of Information Check（信息质量检查）★ 几乎就是为我们写的
**核心机制(逐字)**："Evaluates completeness and soundness of available information sources." 关键洞察：
> "Having multiple sources on an issue is **not a substitute** for having good information that has been thoroughly examined."

方法包括：建一个按"源类型 + 日期 + 强弱注记"组织的数据库；系统复查所有源的准确性；标出最关键/最有说服力的源并检查它们有没有被充分交叉印证；重新审视之前被否决的信息;检查模糊信息有没有被恰当地加注 caveat；对每个源标出可信度等级。
**对我们的借鉴点**：
- "多源不等于好证据"直接打脸一个常见误区——我们的交叉验证规则(C 级查一个、D 级查两个)是在数源的数量，但 CIA 提醒**数量不能替代单源的质量审查**。可以加一条规则：交叉验证前先确认这几个源是不是真独立(防循环报告)。
- "重新审视之前被否决的信息"——我们的 Claim Ledger 现在是单向的(unverified → confirmed/contradicted)，没有"翻案"机制。新证据出现时，contradicted 的 claim 应该能被重新激活。
- Iraq WMD 案例的教训(CIA 原文引参议院报告)："over-reliance on a single, ambiguous source"——单一模糊源是最大的失败模式。我们应该给"只有一个源 + 该源表述模糊"的 claim 打最高风险标记。

### 4b. Key Assumptions Check（关键假设检查）
**四步法(CIA 原文逐字)**：
1. "Review what the current analytic line on this issue appears to be; write it down for all to see."
2. "Articulate all the premises, both stated and unstated... which are accepted as true for this analytic line to be valid."
3. "Challenge each assumption, asking why it 'must' be true and whether it remains valid under all conditions."
4. "Refine the list of key assumptions to contain only those that 'must be true'... consider under what conditions or in the face of what information these assumptions might not hold."
**对我们的借鉴点**：AI 的结论往往建在**未明说的前提**上。质证前应该先把 AI 这条 claim 隐含的前提抠出来单独质证。比如 AI 说"公司 2025 营收破亿"，隐含前提可能是"它用的是历年同一口径"——这个前提本身要单独验。

### 4c. Devil's Advocacy（魔鬼代言人）
**核心机制(逐字)**："Challenging a single, strongly held view or consensus by building the **best possible case for an alternative** explanation." 方法：勾出主流判断和关键假设 → 挑最经不起推敲的那个假设 → 审查支撑它的信息是否有效、是否有欺骗、是否有大缺口。
**对我们的借鉴点**：对 AI 给的高置信度结论，专门派一轮"魔鬼代言"——不是随便挑刺，而是**认真为相反结论建最强论证**。这比单纯问"对不对"更能暴露盲区。对应我们 evidence-rules.md 的对抗步骤，可以升级成"为反方建最强 case"而不只是"找漏洞"。

---

## 五、史学考证：Source Criticism（内部考证 vs 外部考证）

**来源领域**：历史学方法论(可追到 19 世纪兰克学派 / Bernheim、Langlois & Seignobos)
**来源链接**：
- 维基方法论条目：https://en.wikipedia.org/wiki/Historical_method
- Source criticism：https://grokipedia.com/page/Source_criticism

**核心机制**：考证分两层，**先外后内**：
- **外部考证(External Criticism)**：解决"这东西是真的吗"——鉴定来源(provenance)、作者、成文日期、材料完整性,确认它不是伪造。"External criticism assesses a source's provenance, including authorship, date of creation, and material integrity, to confirm its genuineness before interpretation."
- **内部考证(Internal Criticism)**：解决"这东西说的可信吗"——在确认是真品后，再查内容的准确性、作者意图、有没有因意识形态/立场造成的扭曲。"Internal criticism then probes the content for accuracy, intent, and distortions arising from the author's ideological, cultural, or political context."
- 两条经典可靠性原则：
  - "If a number of independent sources contain the same message, the credibility of the message is strongly increased."(独立多源印证 = 可信度大增)
  - "The closer a source is to the event which it purports to describe, the more one can trust it."(越接近事件的源越可信)

**对我们工作流的潜在借鉴点**：
- **外部考证这一层我们基本是空的**。我们的 A/B/C/D/X 在评源的"类型"，但没问"这个源本身是不是真的/没被篡改/是不是它声称的那个东西"。在 AI 时代这一层正在变致命——AI 可能引用一个不存在的源、伪造的 URL、被篡改的文档。**质证前应该先做一道外部考证**：这个 URL 真的存在吗?这个文档真的是那个机构发的吗?这正好呼应 evidence-rules.md 第 4 条"Web content must include source URLs"，但要再进一步——URL 存在 ≠ URL 内容是真的。
- **「越接近事件越可信」可以量化成一个字段**：源到事件的"距离"(一手亲历 / 转述 / 二次转述)。这比 A/B/C/D 更细——同样是 D 级新闻，引用了现场记者一手采访的，比引用了另一篇报道的，可信度不同。
- **内外两层顺序**：我们现在质证是混在一起做的。可以拆成：先验源真实性(外)，再验内容准确性(内)。源都是假的就没必要验内容了。

---

## 六、新闻业：Two-Source Rule / Corroboration（双源规则 / 交叉印证）

**来源领域**：新闻业职业规范(SPJ Code of Ethics、各大报内部手册，水门事件后成为行业标准)
**来源链接**：
- SPJ 准则 + 验证标准：https://fiveable.me/law-and-ethics-of-journalism/unit-8/standards-accuracy-verification/study-guide/OmP6WFbjnhbRJHXd
- 交叉印证：https://fiveable.me/journalism-research/unit-8/cross-referencing-corroborating-information/study-guide/9c0xgtTp1V9hnXk3
- 加拿大报业实证研究(单源够不够)：http://cca.kingsjournalism.com/?p=167

**核心机制**：
- **双源规则**：一个事实在发表前必须由**至少两个独立信源**确认。"facts must be confirmed by at least two independent sources before publication."
- 关键词是 **independent**——两个源必须是真正独立的，不能是同一个原始源的两次转述(这就是「循环报告 circular reporting」陷阱)。
- **留痕**："Journalists should maintain detailed records of their fact-checking process, including sources consulted, evidence reviewed, and verification methods used." ——核查过程本身要可审计。
- SPJ 第一原则"Seek truth and report it"，把准确和验证定为**义务**而非追求("direct obligations rather than aspirational goals")。

**对我们工作流的潜在借鉴点**：
- **「独立性」是我们交叉验证规则里缺的一环**。evidence-rules.md / source-grading.md 说 C 级查一个、D 级查两个，但没要求确认这些源**彼此独立**。如果 NLM 里三个源其实都引用同一个原始新闻稿，那"三源印证"是假的。应该加一条：交叉验证时标注每个源的**原始出处链**，确认它们不共享同一个上游源。
- **核查过程留痕 = 我们的 Claim Ledger，但可以更狠**：新闻业要求记下"用了什么方法验的"。我们的 Claim Ledger 有 source quote / source / confidence，可以再加一列 **verification method**(怎么验的——直接引用 / 交叉两源 / 反证检查)，让整条链彻底可审计。
- **义务而非追求**：把"absence of evidence is a valid finding"(evidence-rules.md 第 11 条)和 SPJ 的"义务"精神对齐——宁可留空格也不填猜测，这是硬纪律不是软建议。

---

## 七、系统综述：PRISMA 2020（系统综述报告标准）

**来源领域**：循证医学 / 系统综述方法学(PRISMA Statement，27 项清单 + 四阶段流程图)
**来源链接**：
- 官网流程图：https://www.prisma-statement.org/prisma-2020-flow-diagram
- PRISMA-S 常见问题：https://pmc.ncbi.nlm.nih.gov/articles/PMC9014944/

**核心机制**：PRISMA 流程图把"从一堆候选材料里怎么筛到最终纳入的"全程可视化、可审计。四个阶段：identification(识别) → screening(筛查) → eligibility(合格性) → included(纳入)。每个阶段都要记**数字 + 排除理由**：
- 识别了多少条记录、去重删了多少。
- 筛查了多少、**排除了多少 + 每条排除的理由**。
- 全文评估了多少、又排除了多少 + 理由。
- 最终纳入多少。
**最核心的原则**：**每一条被排除的材料都要记录为什么被排除**，让整个筛选过程外人可复核、可复现。"documenting exclusion reasons at each stage... making the entire workflow auditable and reproducible." 另外筛查通常由 2–3 个独立 reviewer 做，分歧靠讨论解决(降低选择偏倚)。

**对我们工作流的潜在借鉴点**：
- **我们记录的是"用了哪些源"，没记录"哪些源被我们扔了、为什么扔"**。这是个盲区。AI 在调研时会看一堆材料然后只引用一部分——被它静默丢弃的那些是看不见的偏倚。可以给工作流加一个**排除日志**：候选源 X 条 → 因为(过期/不相关/不可信/重复)排除 Y 条 → 纳入质证 Z 条。这让 AI 的"挑选"过程从黑箱变成可审计。
- **去重 = 防循环报告的操作化**：PRISMA 的 deduplication 步骤正好对应前面反复出现的"独立性"问题——先去重(识别同一来源的不同副本)，剩下的才算独立源。
- **独立双 reviewer**：呼应 evidence-rules.md 第 8 条"extraction and verification are separate steps"——PRISMA 用两个独立的人筛，我们可以用"提取的 agent ≠ 验证的 agent",已经在做，PRISMA 给了它学理背书。

---

## 八、法律证据规则：可迁移的概念

**来源领域**：英美证据法(Federal Rules of Evidence 等)
**来源链接**：
- Best evidence rule：https://www.law.cornell.edu/wex/best_evidence_rule
- 原件要求：https://www.mass.gov/guide-to-evidence/section-1002-requirement-of-original-best-evidence-rule

法律不是为"求真"设计的(它有可采性/程序正义等额外约束)，但有三个概念能直接迁移：

### 8a. Best Evidence Rule（最佳证据规则 / 原件优先）
**机制**："the original or primary evidence should be presented if available. Copies or secondary evidence may be admissible if the original is unavailable, lost, or destroyed."——要证明一份文件的内容，必须出**原件**;用副本/二手必须说明原件为什么拿不到。
**借鉴点**：对应我们 A 级"primary official documents"。可强化为一条硬规则——**能拿到原始文档就不接受 AI 的转述/摘要**。这正是 evidence-rules.md 第 3 条"PDFs go through NLM"的法理基础：不让 AI 用二手摘要代替原件。如果只能用二手，Claim Ledger 必须注明"原件不可得，原因是 X"。

### 8b. Hearsay（传闻证据规则）
**机制**：传闻(转述别人说的话来证明该话内容为真)原则上不可采，除非落入例外。
**借鉴点**：AI 经常干的就是 hearsay——"据某报道，X 公司说……"。这种**转述的转述**应该默认降级，除非能追到原始陈述。可以给 Claim Ledger 的 source 字段加一个 hearsay 标记：这条 quote 是源本身的陈述，还是源在转述第三方?后者要追到一手或显著降权。

### 8c. Chain of Custody（证据链 / 保管链）
**机制**："a consistent trail showing the path of the item from the time it was acquired until the moment it is presented into evidence."——一份证据从获取到呈堂，每一手交接都要有记录，断链就质疑其完整性。
**借鉴点**：对应可万记忆里的 **raw/ 双轨制**(original/ + extracted/)——这本质就是证据链思维。可以再补完整：从「原始 URL → curl 抓的原文落 original/ → WebFetch 提取落 extracted/ → 灌 NLM → NLM 引用 → 进 Claim Ledger」，每一手都留痕。任何一环断了(比如 AI 引用的 quote 在 original/ 里找不到对应),这条证据链就断了,该 claim 不可信。这把"AI 引用的原文是否真的在源里"变成一个可机械检查的环节。

---

## 【最值得借鉴的 3 个点】

**1. 把单维 A/B/C/D/X 升级成 Admiralty Code 式的双维打分(信源可靠性 × 信息可信度)。**
这是最直接、最高杠杆的一步。我们现在的 A/B/C/D/X 把"源可不可信"和"这条具体信息可不可信"压成了一个字母,丢掉了一整个维度。Admiralty 几十年的实践证明这两件事必须分开评、互不污染:一份官方年报(A级源)谈自己竞争优势那条 claim,可信度可能只有 4(源可靠但内容存疑、无第二源印证);一篇二手新闻(D级源)如果被三个真正独立的源交叉确认,可信度可以到 1,实际比 A4 更可信。落地方式:Claim Ledger 每条 claim 打一个双字符码(如 `A4`/`D1`),字母维沿用现有信源分级,数字维由置信度 + 交叉印证情况决定。这一步直接补上了我们体系最大的结构性缺口,而且几乎零成本(只是把已有的两类判断显式分开)。

**2. 引入 ACH 的「找反证而非找支持」逻辑 + 诊断价值概念。**
我们现在的质证流程本质还是"提假设 → 问 NLM 证据在哪",这是在**找支持**。ACH 的核心翻转是:对每条 claim 主动问"**源材料里有没有任何东西和它矛盾**",并且列出竞争假设并排打分,最可信的是"反证最少"的那个,不是"支持最多"的那个。配套的诊断价值(diagnosticity)概念也极有用:一条证据如果对所有可能解释都成立,它其实没区分力、要降权;只有能把假设区分开的证据才算数。这条专治 AI 的高置信度幻觉——LLM 最爱"第一个看起来对的答案",ACH 强制它把所有合理替代解释摆上台面平等对待。落地:对抗步骤从"找漏洞"升级成"为相反结论建最强 case"+ 用 C/I/N 矩阵逐条证据横扫。

**3. 用 PRISMA 的「排除留痕」+ 新闻业/史学的「源独立性」堵住两个隐形偏倚。**
两个我们现在完全看不见的盲区:一是 AI 调研时**静默丢弃**了哪些材料、为什么丢(被丢弃的那些是看不见的选择偏倚);二是所谓"多源印证"里的源**到底独不独立**(同一个原始新闻稿被转述三遍,看着像三源,其实是一源,这是「循环报告」陷阱)。PRISMA 的解法是排除日志(候选 X 条 → 排除 Y 条 + 每条理由 → 纳入 Z 条,全程可复核);新闻业双源规则和史学考证的解法是强制确认源的**真正独立性**(标注每个源的原始出处链,先去重再数源)。这两条合起来,把 AI 的"挑选"和"印证"从黑箱变成可审计——而可审计正是整个工作流"靠谱"的地基。

---

## 附:一手源清单(可追溯)

| 方法 | 一手/权威源 | 类型 |
|------|------------|------|
| Admiralty Code | en.wikipedia.org/wiki/Admiralty_code (源自 NATO STANAG 2511) | 方法论条目,定义逐字 |
| GRADE | pmc.ncbi.nlm.nih.gov/articles/PMC2335261 (BMJ consensus) + gradeworkinggroup.org | 原始 consensus 论文 |
| ACH + SATs | cia.gov/resources/csi/static/Tradecraft-Primer-apr09.pdf | CIA 官方手册原文(本地已读 PDF) |
| Source criticism | en.wikipedia.org/wiki/Historical_method | 方法论条目 |
| Two-source rule | SPJ Code of Ethics + fiveable 新闻伦理教材 | 行业规范 |
| PRISMA 2020 | prisma-statement.org/prisma-2020-flow-diagram | 官方标准 |
| 法律证据 | law.cornell.edu/wex (LII) + mass.gov guide-to-evidence | 法条注释 |

**说明**:CIA Tradecraft Primer 的 ACH 矩阵机制、Quality of Information Check、Key Assumptions Check 四步法、Devil's Advocacy 方法,均直接读自官方 PDF 原文(2009 版),引号内英文为逐字抄录。Admiralty Code 的 A-F / 1-6 完整定义来自维基方法论条目逐字。GRADE 四级定义和升降级因素来自 consensus 论文逐字。未找到 Admiralty Code 对「循环报告」的直接论述(维基和该实践文章都未直接展开),该问题由新闻业 two-source rule 和史学考证的「独立源」原则补足,已在报告中标注。
