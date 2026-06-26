# 工业界 AI 系统的证据核验与事实 grounding 前沿实践

调研日期: 2026-06-25
目的: 为 zuoshi-kaopu 工作流(LLM 假设引擎 + NotebookLM 证据引擎)寻找可借鉴的工业界机制
方法: 英文 query web 搜索 + 一手源深读。一手源 = 官方博客/论文/官方文档。

> 现有工作流已有的东西(对照基准): 假设/证据引擎分工 / Claim Ledger 四字段(结论·原文引用·来源标识·置信度) / 置信度 direct·indirect·no_data·source_conflict / 信源分级 A·B·C·D·X / raw 双轨落盘(原文 + 提取版)。
> 本报告只找"现有体系还没有、或做得不够"的机制。

---

## 一、Anthropic 多 Agent Research 系统

### 【独立 CitationAgent(引用专职 pass)】
- 来源: Anthropic 官方工程博客 "How we built our multi-agent research system",2025-06-13。一手源。https://www.anthropic.com/engineering/multi-agent-research-system
- 核心机制: 整个系统是 orchestrator-worker 结构。主 agent 规划并派 3-5 个子 agent 并行搜索综合。关键点在于: **引用不是在写作时顺手生成的,而是一个独立的最后阶段**。研究循环结束后,系统退出循环,把"所有 findings + 研究报告草稿"一起交给一个专门的 CitationAgent,由它逐条把 claim 映射回源材料的具体位置,确保每条 claim 都被正确归因(原文: "passes all findings to a CitationAgent, which processes the documents and research report to identify specific locations for citations. This ensures all claims are properly attributed to their sources")。
- 借鉴点: 现有工作流的质证和写作是混在 Step 3/5 的。可以把"引用归因"独立成一个专职 pass,在终稿冻结后,拿成品文本逐句回扫源材料,而不是在生成时边写边标 —— 写作时标引用容易出现"引用漂移"(claim 改了引用没跟上)。

### 【LLM-as-Judge 五维 rubric 做终检】
- 来源: 同上 Anthropic 博客,2025-06-13。一手源。
- 核心机制: 用一个 LLM judge,单次调用单个 prompt,对每份输出按 rubric 打 0.0-1.0 分 + pass/fail。五个维度: **factual accuracy(claim 是否匹配源)/ citation accuracy(被引的源是否真的对应那条 claim)/ completeness(是否覆盖所有要求)/ source quality(是否用一手源而非低质二手源)/ tool efficiency**。他们发现"单 LLM 单 prompt 出分"比复杂的多步评估更稳定、更贴合人类判断。注意它把 **factual accuracy 和 citation accuracy 拆成两个独立维度** —— claim 本身对 ≠ 引用挂对了地方。
- 借鉴点: 现有 Claim Ledger 的 confidence 字段把"claim 是否成立"和"引用是否挂对"糅在一起了。可以拆成两个独立判定: (1) claim 是否被源支撑 (2) 标注的那条原文引用是否真的是这条 claim 的依据。终稿前跑一遍五维 rubric 自检,是低成本的成品质量门。

### 【源质量启发式写进 prompt(解决"内容农场偏好"）】
- 来源: 同上 Anthropic 博客,2025-06-13。一手源。
- 核心机制: 早期 agent 系统性地偏好 SEO 优化的内容农场,而不是权威但排名低的源(学术 PDF、个人博客)。解法是把"源质量启发式"直接写进 prompt,并给工具选择启发式(先看所有可用工具、按用户意图匹配工具、优先专用工具而非通用工具)。子 agent 用 interleaved thinking 在每次工具返回后评估质量、找缺口、refine 下一个 query。
- 借鉴点: 现有信源分级 A/B/C/D/X 是事后人工打标。Anthropic 的做法是把"优先一手源、警惕内容农场"作为搜索时的实时启发式,在抓取阶段就过滤。可以在搜索环节加一条主动规则,而不是只在落盘后评级。

---

## 二、Deep Research 类产品的核验方法论

### 【OpenAI Deep Research: 多源交叉 + 分级置信度评分】
- 来源: OpenAI 官方 "Introducing deep research" 2025-02 + Deep Research System Card 2025-02-25。一手源。https://openai.com/index/introducing-deep-research/ 和 https://cdn.openai.com/deep-research-system-card.pdf
- 核心机制: agentic 多步流程(搜索→评估源→refine query→综合)。公开材料提到两个机制: **multi-level verification(把信息纳入产出前,在多个独立源之间交叉确认)** 和 **graduated confidence scoring(置信度分级评分,反映证据质量、跨源一致性、推理可靠性)**。但官方也承认会幻觉、会做错误推断(只是比普通 ChatGPT 低)。
- 借鉴点: "graduated confidence scoring 含跨源一致性" 这一点现有体系有对应(source_conflict),但 OpenAI 把"被多少独立源确认"作为置信度的显式输入。可以在 Claim Ledger 加一个"独立源计数"维度: 单源支撑 vs 多源交叉确认,置信度不同。

### 【Perplexity vs Gemini: 引用粒度的两种策略】
- 来源: 二手对比文章(Yext / Indexly / Fritz 等行业博客,2026)。二手源,但描述的是产品公开行为,可观察验证。
- 核心机制: **Perplexity** 用 RAG,设计上"每条事实性 claim 都内联挂一个编号源,几乎每句都能点击核验",优先 traceability。**Gemini** Deep Research 用 search grounding + query decomposition(把用户输入拆成多个小搜索 query),但**不是每句都挂源,只有当内容是直接从搜索结果拉取或高度匹配时才标引用**。这是两种引用粒度哲学: "全覆盖内联" vs "仅直接引用才标"。
- 借鉴点: 这正好对应你要的"区分引用原文 vs 自己综合"。Gemini 的做法是个明确信号: **只有直接来自源的句子才挂引用,综合性句子不假装有源**。现有工作流可以显式区分 claim 类型: 「源直述」必须有原文引用,「跨源综合」标注为综合不挂单一源(但要可追溯到几个源)。

### 【"Cited but Not Verified": 引用核验三维度 + 关键失败数据】
- 来源: arXiv:2605.06635v1 "Cited but Not Verified: Parsing and Evaluating Source Attribution in LLM Deep Research Agents",2026-05-07。预印本(非同行评审),但方法论和数据极对题。https://arxiv.org/html/2605.06635v1
- 核心机制: 把"引用是否可信"拆成**三个互相独立的维度**逐层检查: (1) **Link Works** — URL 是否可访问(HTTP 状态检查,失败分三类: 404/被封 paywall·反爬/超时);(2) **Relevant Content** — 源页面和 claim 是否主题相关(LLM-as-judge);(3) **Fact Check** — 源内容是否真的支撑这条 claim 的具体事实/数字/日期(LLM-as-judge,经人工校准,二元打分: 1=支撑一致,0=矛盾/缺失/不确定)。
- 关键数据(借鉴价值最高): 前沿模型的**链接有效率 94-100%,主题相关率 80-96%,但事实支撑率只有 39-77%**(53% 的跨度,是"最有区分度的维度")。更狠的是: **随搜索深度加深(2→150 次工具调用),Fact Check 准确率平均掉 42%,而表面指标(链接有效)稳定在 92% 以上**。意思是: 链接看着都在、页面看着都相关,但"这条源真的支撑这句话吗"会随研究变长而严重退化,且表面指标完全看不出来。
- 借鉴点: 这三维度应该直接进 Claim Ledger 的检查流程。现有 confidence 字段其实只覆盖了第三层(Fact Check),前两层(链接活着吗、页面真相关吗)没单独查。尤其"链接在 ≠ 内容支撑"和"研究越长引用越虚"这两个结论,提示要在终检阶段对关键 claim 重新逐条做 Fact Check,不能信中途标的引用。

---

## 三、长文本事实性评估: atomic claim 分解(引用粒度的核心技术)

### 【FactScore: 原子事实精度】
- 来源: FactScore 原论文(EMNLP 2023)+ 综述 aman.ai factuality primer。一手 + 二手综述。https://aman.ai/primers/ai/factuality-in-LLMs/
- 核心机制: 三步。(1) 用 GPT-4 把一段生成文本**拆成一串"原子事实"(atomic facts)** —— 每个是最小的、不可再分的事实陈述;(2) 每个原子事实逐个对参考材料验证是否被支撑;(3) 算分: F_act = 被支撑的原子事实数 / 原子事实总数。每个标签都生成人类可读的理由。和专家标注相关性约 0.82。
- 借鉴点: 现有 Claim Ledger 的 claim 颗粒度是"一句结论",但一句话里可能含多个事实(公司 2015 年成立 + 总部在上海 + 创始人是张三 = 3 个原子事实,可能只有 2 个被源支撑)。引入"原子事实拆解"能把"半对的 claim"暴露出来,避免一条 claim 整体标 confirmed 实则只对一半。

### 【SAFE: 搜索增强事实核验 + decontextualization】
- 来源: Google DeepMind "Long-form factuality in large language models" 论文(2024)+ aman.ai 综述。一手。
- 核心机制: (1) 把每句拆成原子事实;(2) **decontextualization(去语境化)阶段** —— 把依赖上下文的 claim 改写成自包含的命题,比如把代词"他""它"解析成具体指代对象,目的是让每个 claim 能脱离原文档独立去搜索验证;(3) 对每个原子事实生成聚焦的搜索 query,取 top 结果;(4) 用 DeBERTa-MNLI 算 claim 和检索片段的蕴含概率;(5) 标签: supported / contradicted / irrelevant(按蕴含阈值)。引入 **F1@K 指标**平衡精度(支撑事实比例)和召回(是否检索到足够支撑证据)。和专家判断相关性约 0.8。
- 借鉴点: **decontextualization 这一步现有工作流完全没有,但对 NLM 质证极关键**。现在拿 claim 去 NLM 质证时,如果 claim 里含"该公司""这个产品"这种指代,NLM 可能找错对象或答不准。在送 NLM 前先做一遍去语境化(把指代展开成具体名称),会显著提升质证命中率。另外 SAFE 的三标签(supported/contradicted/irrelevant)里的 "irrelevant" 现有体系没有 —— 源里有相关内容但不针对这条 claim,这种"擦边但不支撑"现在容易被误判成 indirect。

---

## 四、RAG faithfulness / groundedness 评估方法

### 【RAGAS: 四指标,核心是 Faithfulness 拆 claim 逐条质证】
- 来源: RAGAS 官方文档(持续更新)。一手。https://docs.ragas.io/en/stable/concepts/metrics/available_metrics/faithfulness/
- 核心机制: 四个指标全部输出 0-1 分。**Faithfulness(忠实度)** 两步: 先用 LLM 把答案拆成一组独立 claim,再对每条 claim 判断能否从 retrieved context 推断,得分 = 被支持的 claim 数 / 总 claim 数(2 条 claim 1 条无法推断 = 0.5),不需要 ground truth。**Answer Relevancy** 反向生成法: 用答案反向生成 n 个潜在问题,算与原问题的 embedding 相似度取平均。**Context Precision** 衡量检索排序质量(相关 chunk 是否排前)。**Context Recall** 把参考答案拆 claim,算每条能被 retrieved context 支持的比例(唯一严格需要 ground truth 的指标)。
- 借鉴点: **Context Recall 对应现有体系缺的"漏报检测"** —— 现在只验证"已写结论有没有源",没反查"源里关键信息有没有被结论遗漏"。Faithfulness 的"被支持/总数"可做成 Claim Ledger 的一个量化汇总分。

### 【FACTS Grounding: 资格性 + 准确性双闸 + 多 judge 去偏】
- 来源: Google DeepMind 官方博客 + arXiv:2501.03200,2025-01。一手。https://deepmind.google/blog/facts-grounding-a-new-benchmark-for-evaluating-the-factuality-of-large-language-models/
- 核心机制: 1719 个例子,输入文档最长 32K token,刻意排除需要创造力/数学/复杂推理的任务。**两步评分: (1) 资格性 eligibility —— 先判断响应是否充分回应了用户请求,不合格直接判 0(防止"答非所问但不出错"刷分);(2) 事实准确性 grounding accuracy —— 只有完全基于文档无幻觉才算准确。** 用三个 judge 模型 ensemble(Gemini 1.5 Pro + GPT-4o + Claude 3.5 Sonnet),目的是消除"judge 偏爱自家模型家族"的偏见。
- 借鉴点: **"资格性前置闸"现有体系没有** —— 现在盯"结论有没有源",但没先卡一道"这结论是否真的回应了原始研究问题",会出现"每条都有源但整体跑题"。多 judge ensemble 给出"为什么不能只用一个模型质证"的实证理由(同家族偏袒),印证多模型协作纪律。

### 【TruLens RAG Triad: 三角分工 + 故障定位】
- 来源: TruLens 官方文档。一手。https://www.trulens.org/getting_started/core_concepts/rag_triad/
- 核心机制: 三角全部 reference-free,全部 LLM-as-judge。**Context Relevance**(逐 chunk 评估和 query 相关性,管检索质量)/ **Groundedness**(答案拆 claim 逐条在 context 找支持,管不幻觉)/ **Answer Relevance**(最终答案和 query 契合度,管答到点上)。三角逻辑: 三角都过关反推链路无幻觉,且能定位问题出在检索端还是生成端。
- 借鉴点: **"故障定位"让置信度可诊断** —— 现有四字段能判断"信不信",不能判断"为什么不可信"。把失败原因区分成"源没检索到(Context)"和"源有但结论没扣住源(Groundedness)",对应补救动作完全不同(补源 vs 改写结论)。

### 【ALCE: Citation Recall / Precision,用 NLI 自动测引用】
- 来源: ALCE 论文 arXiv:2305.14627 + 属性化综述 arXiv:2508.15396(2025-08)。一手。https://arxiv.org/pdf/2305.14627
- 核心机制: 第一个大规模带引用文本生成 benchmark,以"短文本跨度引用"为标准,用 NLI 模型自动算。**Citation Recall**: 把某句引用的所有文档拼起来,判断是否 entail 这句生成内容(衡量"这句是否被它引的源完整支持")。**Citation Precision**: 逐个移除引用文档,看剩下的是否还能 entail 这句话 —— 移除某文档后仍蕴含,说明该引用冗余/无关(衡量"有没有挂无用引用")。综述指出 **高达 57% 的引用是事后补的(post-rationalization)、并非真实推理依据**。句级引用比段落级对人更有用。
- 借鉴点: **Citation Precision 的"移除源测试"现有体系完全没有** —— 逐条移除源看结论是否还成立,能抓"挂了源但其实没用上"的虚假引用,这正是 57% post-rationalization 风险在本工作流的对应。句级引用标准支持把 Claim Ledger 引用粒度收紧到句级。

---

## 五、LLM 自核验技术

### 【Chain-of-Verification (CoVe): factored 隔离验证】
- 来源: ACL 2024 Findings / arXiv:2309.11495,Meta AI。一手。https://arxiv.org/abs/2309.11495
- 核心机制: 四步。(1) 生成初始回答 baseline;(2) 针对 baseline 里的事实点规划一组验证问题;(3) 独立回答这些验证问题;(4) 基于验证结果生成最终修正回答。第三步有四种变体,**Factored(每个验证问题在独立 prompt 里单独回答,彼此看不见,也看不见原始 baseline)显著最好**,原因是隔离验证能避免重复幻觉 —— 如果验证答案能看到原始(可能错的)baseline,会被带偏、把同一个幻觉再说一遍。
- 借鉴点: **"验证必须在看不到原始结论的独立上下文里进行"这条 factored 原则,正是"Claude 提假设、NLM 用原文质证,反过来不行"的机制级背书** —— CoVe 用实验解释了为什么必须隔离(防错误传播)。还可借: 质证不是笼统问"对不对",而是先把结论拆成一组具体验证问题再逐条丢 NLM。

### 【Self-RAG: reflection tokens,IsSup 三档支持度】
- 来源: arXiv:2310.11511。一手。https://arxiv.org/html/2310.11511
- 核心机制: 训练单模型边生成边输出四类 reflection token。**Retrieve**{yes,no,continue}(按需检索,不是每次都检)/ **IsRel**{relevant,irrelevant}(检索段落是否有用)/ **IsSup**{fully supported, partially supported, no support}(输出被段落支持的程度,**三档不是二元**)/ **IsUse**{1-5}(整体有用性打分)。推理时 segment 级 beam search,批判分把三组 token 归一化加权,权重可调(高风险任务调高 IsSup 权重逼模型更看重证据)。
- 借鉴点: **IsSup 三档比现有 direct/indirect 更细在"部分支持"** —— 可把 indirect 拆成"部分支持(源说了一半)"和"间接推断(源没直说要靠推)"。**Retrieve token = 按需质证**: 常识/定义类结论跳过 NLM,只有事实性声明才进 NLM,省调用成本。权重可调对应信源分级,高风险结论提高证据档位要求。

### 【Self-Consistency: 多次采样投票,做假设预筛】
- 来源: arXiv:2203.11171,Wang et al. 2022。一手(经典奠基)。
- 核心机制: 三步。(1) CoT prompt;(2) 从 decoder 采样多条不同推理链(不是贪心单条);(3) 对所有最终答案取多数投票。直觉: 同一正确答案能从多条不同路径殊途同归则更可信。
- 借鉴点: 用在"假设引擎"环节做预筛 —— 同一研究问题让 Claude 多次独立采样,**多次收敛的结论先验置信度高、优先送 NLM;每次都不同(高方差)说明在编,重点警惕**。在质证前给假设加一道自洽性预筛,过滤低质量假设省后续质证成本。注意它只测一致性不测对错,不能替代 NLM 原文质证。

### 【Self-Refine: 反面参照,自评不能做事实核查】
- 来源: arXiv:2303.17651。一手。https://arxiv.org/abs/2303.17651
- 核心机制: 同一 LLM 扮演生成者/反馈者/修订者三角色,生成→自我反馈→修订循环,无需训练/标注/RL,7 个任务平均提升约 20%。
- 借鉴点(反面): **它让同一模型自评自纠,正好违反"不能自己质证自己"的纪律** —— 能改善流畅性和格式,但对事实核查无能(模型对自己的幻觉同样自信)。能借的只有"迭代修订"外壳: NLM 质证发现 source_conflict 后把冲突喂回 Claude 改写再质证,但反馈必须来自 NLM 外部证据,不是 Claude 自评。

### 【RARR: 事后归因 + 最小编辑修正(整体形态最贴合)】
- 来源: ar5iv HTML 2210.08726 / ACL 2023,Google。一手。https://ar5iv.labs.arxiv.org/html/2210.08726
- 核心机制: 对已生成文本做事后归因 + 修正,"保留原文前提下修复无支持内容"。**Research 阶段**: few-shot 生成覆盖文本所有可验证面的 comprehensive questions(**采样三次取并集**增加覆盖),每问 Google 检索 5 网页,滑动窗口提取候选证据。**Revision 阶段**: (1) **Agreement model 用 CoT** —— 先分别陈述证据这边和文本这边各自暗示的答案,再判断是否一致(不直接问"一致吗");(2) **Edit model 只在检测到不一致时运行**,定位需改的具体跨度后生成修订,**拒绝编辑距离 > 50 字符或 > 原文 0.5 倍的改动(强制最小修改)**。两个评估维度: Attribution(改写后多少能归因到证据)和 Preservation(原意保留 + 编辑最小性)。
- 借鉴点: **整体形态最像本工作流(事后给结论挂证据并修正)**。三点可借: (1) comprehensive questions 采样三次取并集,保证质证问题不漏点;(2) Agreement model 的 CoT —— 先分别说出证据侧和结论侧各自的答案再比对,让 source_conflict 判定更可审计;(3) **Preservation + 最小编辑约束** —— 质证发现冲突后修订结论时强制最小改动、保留原意,避免"为对齐源把结论改得面目全非",这是做"质证-修订"闭环时缺的护栏。

---

## 六、最值得借鉴的 3 个点

筛选标准: 现有体系真的没有 + 可操作 + 能堵住一类真实的失败模式。

### 1. 把 claim 拆成"原子事实"+ 送 NLM 前做去语境化(FactScore / SAFE / RAGAS Faithfulness 三方印证)

现有 Claim Ledger 一条 claim 是"一句结论",但一句话常含多个事实(成立年份 + 总部 + 创始人 = 3 个原子事实,可能只有 2 个被源支撑),整条标 confirmed 会把"半对的 claim"当全对。三个工业系统都用同一招: **先把结论拆成最小不可分的原子事实,再逐条质证,算"被支持数/总数"**。配套 SAFE 的 **decontextualization**: 送 NLM 前把"该公司""这个产品"这类指代展开成具体名称,否则 NLM 容易找错对象或答不准。这一步对 NLM 质证的命中率是直接增益,且几乎零额外成本。落地: Claim Ledger 增加"原子事实拆分"子行,质证粒度从句级降到原子事实级,confidence 从整条标改成逐原子事实标。

### 2. 引用核验拆成三层独立检查,并在终稿冻结后重做一遍 Fact Check("Cited but Not Verified" + ALCE)

现有 confidence 字段实际只覆盖了"源是否支撑 claim"这一层,且是在质证当下标的。两个发现联手指出风险: (1) "Cited but Not Verified" 实测**链接有效率 94-100%、主题相关率 80-96%,但事实支撑率只有 39-77%,且随研究变长(2→150 次工具调用)Fact Check 准确率平均掉 42%,而表面指标完全看不出来** —— 中途标的引用不可信。(2) ALCE 的 **Citation Precision 移除源测试**(逐条移除源看结论是否还成立)能抓"挂了源但没用上"的虚假引用,对应 57% 引用是事后补的这一普遍问题。落地: 把引用检查拆成"链接活着吗 / 页面真相关吗 / 原文真支撑这条 claim 吗"三层分开记;**终稿冻结后对所有关键 claim 重做一遍逐条 Fact Check**,不信中途标的;对存疑引用做一次"移除源"反向验证。

### 3. 加两道现在完全没有的"边界闸": 资格性前置闸 + 漏报反查(FACTS Grounding + RAGAS Context Recall)

现有体系是"逐条 claim 是否有源"的正向检查,有两个系统性盲区,工业界都有对应机制堵: (1) **资格性闸(FACTS Grounding)** —— 逐条质证前先卡一道"这份产出整体是否真的回应了原始研究问题",不合格直接判 0,堵住"每条都有源但整体跑题"。(2) **漏报反查(RAGAS Context Recall)** —— 不只验"已写结论有没有源",还要反查"源里该被覆盖的关键信息有没有被结论遗漏",堵住"挑着说、报喜不报忧"。这两道闸一个管"答得对不对题",一个管"该说的有没有漏",和现有的"说的对不对"正交,补的是完全不同的失败维度。落地: 在 5 问自检阶段前加资格性判断;质证时除了正向核 claim,加一轮"源里有但 Ledger 没收"的反向扫描。

---

### 附: 一条值得记住的反面警示

Self-Refine 证明"让同一个模型自评自纠"对事实核查无效(模型对自己的幻觉同样自信),CoVe 的 factored 实验证明"验证必须在看不到原始结论的隔离上下文里做"。两者双向印证了"Claude=假设引擎、NLM=证据引擎,不能自己质证自己"这条已有纪律是对的 —— 不要被任何"让 Claude 自己再检查一遍"的便利诱惑动摇这条边界。
