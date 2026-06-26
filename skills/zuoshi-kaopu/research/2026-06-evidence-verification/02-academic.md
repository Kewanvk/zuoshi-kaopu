# 学术界自动化事实核验 / 声明验证 / 归因方法论调研

> 目的：为优化"用源材料质证 AI 结论"的工作流（NotebookLM 质证 + Claim Ledger + 信源分级 + 错误模式清单）寻找学术界成熟机制的借鉴点。
> 调研日期：2026-06-25
> 证据纪律说明：以下所有方法的机制描述均来自 arXiv 一手论文（ar5iv HTML 全文或 PDF），关键定义已尽量摘录原文。找不到原文确认的数字不写。

---

## 0. 学术界的标准 pipeline（先建立全局地图）

来自 Guo, Schlichtkrull, Vlachos 的权威综述（见方法 6），学术界把自动事实核验统一成四个串行阶段：

1. **Claim Detection（声明识别 / check-worthiness）** — 找出值得核查的声明
2. **Evidence Retrieval（证据检索）** — 找支持或反驳该声明的源
3. **Verdict Prediction（裁决预测 / veracity prediction）** — 给声明打真伪标签
4. **Justification Production（理据生成）** — 为裁决产出可解释的说明

可万的工作流已经天然覆盖了 2、3、4（NLM 检索原文 = 证据检索；置信度标签 = 裁决；原文引用 = 理据）。**最薄弱的是第 1 阶段（claim detection / 拆解 / check-worthiness）和裁决标签体系的精细度。** 下面的方法多数在补这两块。

---

## 1. FEVER（Fact Extraction and VERification）

- **作者/年份**：Thorne, Vlachos, Christodoulopoulos, Mittal，2018（NAACL-HLT）
- **来源**：arXiv:1803.05355 — https://arxiv.org/abs/1803.05355 ｜ ACL: https://aclanthology.org/N18-1074/
- **核心机制**：
  - 这是 claim verification 领域的奠基范式。185,445 条声明（改写自 Wikipedia 句子），每条声明走标准三段流水线：claim → 证据检索（从 Wikipedia 找句子）→ 裁决。
  - 标准三分类裁决：**SUPPORTED / REFUTED / NOT ENOUGH INFO（NEI）**。这套三标签后来成为整个领域的事实标准。
  - 关键纪律：对 SUPPORTED 和 REFUTED 两类，标注者**必须同时记录构成判断依据的具体句子（evidence sentences）**，不允许只给结论不给证据。NEI 类则记录"找不到足够证据"。
- **对我们工作流的借鉴点**：
  - 三分类的精神 = 我们的 direct（SUPPORTED）/ source_conflict 部分对应 REFUTED / no_data（NEI）。**FEVER 把"被反驳"和"没数据"明确分成两个独立标签，正好对应可万错误模式清单里"混淆没数据和被反驳"这条**——学术界从 2018 年就把这两者结构上分开了。
  - "不允许只给结论不记录 evidence sentences"= 我们 Claim Ledger 里"每条结论必须有原文引用"的硬纪律，方向完全一致。

---

## 2. RARR（Researching and Revising what LMs say）

- **作者/年份**：Gao, Dai, Pasupat, Chen, ... Guu（Google），2023（ACL）
- **来源**：arXiv:2210.08726 — https://arxiv.org/abs/2210.08726 ｜ 代码: https://github.com/anthonywchen/RARR
- **核心机制**（两阶段：Research → Revise）：
  1. **Research 阶段**：对 LM 输出做"comprehensive question generation（CQGen）"——生成一组覆盖输出**所有方面**的验证问题（采样三次取并集），每个问题用 Google Search 检索证据。这是"把一段话拆成一组可独立查证的问题"的做法。
  2. **Revise 阶段**：用 agreement model 判断证据是否与当前输出冲突；若冲突，用 edit model 改写文本"使其与证据一致，同时尽量少改原文"（拒绝编辑距离 > 50 字符或超过原文 0.5 倍的改动）。
- **两个评估轴（很重要，是双目标权衡）**：
  - **Attribution（归因，基于 AIS = Attributable to Identified Sources）**：每个句子是否能被检索到的证据完全支持。自动版用 NLI 蕴含打分。
  - **Preservation（保真）**：改写后保留了多少原意（意图保留二值 × Levenshtein 编辑距离）。
  - 最终报告两轴的调和平均 F1（attribution-preservation 权衡）。
- **对我们工作流的借鉴点**：
  - **CQGen = 把"质证一个结论"升级成"为这个结论自动生成一组覆盖各方面的查证问题"**，再逐题去 NLM 找证据。比起人工想一个 query，这套"覆盖所有方面的问题集"能减少漏检，直接对治"单源依赖"。
  - **Attribution 这个轴 = AIS（是否可归因到已识别的源）**，比"置信度"更操作化：一条结论不是"我觉得 direct"，而是"这句话能否被某个具体源完全蕴含"。这正是可万要的"用源材料质证"的学术化定义。

---

## 3. ALCE（Enabling LLMs to Generate Text with Citations）

- **作者/年份**：Gao, Yen, Yu, Chen（Princeton），2023（EMNLP）
- **来源**：arXiv:2305.14627 — https://arxiv.org/abs/2305.14627 ｜ 代码: https://github.com/princeton-nlp/ALCE
- **核心机制**——这是**引用质量量化的金标准**，三个评估维度：fluency（流畅度）、correctness（正确性）、citation quality（引用质量）。引用质量拆成 recall 和 precision，用 NLI 模型（TRUE）判蕴含：
  - **Citation Recall（引用召回）**：一条 statement 的 citation recall = 1，当且仅当 ① 它至少有一个引用，且 ② 所有被引段落拼接起来能蕴含这条 statement（`φ(concat(citations), statement) = 1`）。直白说：**每句话都得有引用，且这些引用合起来真能撑住这句话。**
  - **Citation Precision（引用精确度）**：检测"冗余/无关引用"。一个引用 c 被判为 irrelevant，当且仅当 ① 它单独无法支持这条 statement（`φ(c, s) = 0`），**且** ② 去掉它之后剩下的引用仍然能完全支持（`φ(rest, s) = 1`）。即：**这条引用既没用、又可有可无 → 算它拉低精确度。**
  - **Statement 切分粒度**：默认按句子边界切（sentence-level）；列表型答案按每个列表项切；长答案（ELI5）用 LLM 生成 3 条 sub-claims 再判蕴含（claim recall）。
- **对我们工作流的借鉴点**：
  - **把"引用"量化成 recall + precision 两个独立指标**，是 Claim Ledger 可以直接吸收的：recall 管"是否每条结论都挂了原文引用"，precision 管"挂的引用是不是真撑得住、有没有凑数的无关引用"。可万错误模式里"把综合当证据"本质就是 precision 失败（引用看似有、实则不蕴含结论）。
  - **"冗余引用"的两条件判定法**可直接做成 NLM 质证后的自检：去掉某条引用，结论还成立吗？如果成立且这条引用单独又撑不住，就该删——防止用一堆弱引用堆出"看着有据"的假象。

---

## 4. SAFE（Search-Augmented Factuality Evaluator）/ Long-form Factuality

- **作者/年份**：Wei, Yang, ... Le（Google DeepMind + Stanford），2024
- **来源**：arXiv:2403.18802 — https://arxiv.org/abs/2403.18802 ｜ 代码: https://github.com/google-deepmind/long-form-factuality
- **核心机制**（长文本逐条原子核验的代表作）：
  1. **拆原子事实**：提示 LM"把长回答里的每个句子拆成一条条独立事实"。
  2. **自包含改写（revision / decontextualization）**：再让模型"把每条事实改写成自包含的——把代词等模糊指代替换成它在上下文里真正指的实体"。这步很关键：拆出来的事实必须脱离上下文也能独立查证。
  3. **相关性判断**：让模型"判断这条事实在回答该 prompt 的语境下是否相关"，剔除不该评分的句子（如"我不知道答案"）。
  4. **逐事实多步检索核验**：对每条事实，模型迭代地"基于待核验事实 + 已获得的搜索结果生成搜索 query"，跑若干步后做推理，判定该事实是否被搜索结果支持。
  - **每条事实三分类裁决**：**supported / not supported / irrelevant**。
  - **F1@K 指标**：`F1@K = 2·Prec·R_K / (Prec + R_K)`，其中 `Prec = S/(S+N)`（S=支持数，N=不支持数），`R_K = min(S/K, 1)`。**K = 用户偏好的回答长度（达到满分召回所需的支持事实数）**。这个设计同时惩罚"不准"（precision）和"信息量不够"（recall），K 让长度可调。
- **对我们工作流的借鉴点**：
  - **第 2 步"自包含改写"是可万工作流缺的一环**：从 AI 结论里抽出一条声明去 NLM 质证前，应先把它改写成脱离原文也能独立成立的句子（消解代词、补全主语）。否则 NLM 拿到一个含"它/这个/上述"的半截声明，质证结果不可信。
  - **supported / not supported / irrelevant 三分类**：注意 irrelevant 这一档——有些 AI 结论根本不是事实性声明（是观点、是过渡句），不该进 Claim Ledger 质证。可万的 check-worthiness 第一步就该先筛掉 irrelevant。
  - **F1@K 的 recall 思路**：质证不光看"挂出来的结论对不对"，还要看"该覆盖的关键事实有没有都覆盖到"。防止只挑好查的查、难查的略过。

---

## 5. Chain-of-Verification（CoVe）

- **作者/年份**：Dhuliawala, Komeili, Xu, Raileanu, Li, Celikyilmaz, Weston（Meta AI），2023
- **来源**：arXiv:2309.11495 — https://arxiv.org/abs/2309.11495 ｜ ACL: https://aclanthology.org/2024.findings-acl.212/
- **核心机制**（四步）：
  1. **生成基线回答**（baseline response）。
  2. **规划验证问题**（plan verifications）：让模型针对自己的回答生成一组验证问题，自查有无错误。
  3. **独立执行验证**（execute verifications）：逐题作答，并和原回答对照找不一致。
  4. **生成最终修正回答**（final verified response）：把验证结果纳入，输出修订版。
- **最关键的洞见（独立性）**：模型会"注意到自己上文里已有的幻觉，从而重复这些幻觉（context contamination）"。所以**验证问题必须在看不到原回答的前提下独立作答**——论文报告独立作答时单个实体准确率约 70%，而原长答案里只有约 17%。
- **四个变体**（独立性递增，效果递增）：
  - **Joint**：规划+作答一个 prompt，验证答案能看到原回答（最差）。
  - **2-Step**：规划和执行分开，执行 prompt 不含原回答。
  - **Factored**：每个问题独立 prompt，彻底隔绝问题之间和与原回答的干扰。
  - **Factor+Revise**：在 Factored 基础上加显式交叉核对步骤，标出一致/不一致的事实。
- **对我们工作流的借鉴点**：
  - **这是对"诱导性提问"错误模式最直接的解药**。可万现在是 LLM 提假设 → NLM 质证。CoVe 的洞见提醒：**让 LLM 在能看到自己原结论的语境下去"自证"，它会顺着原结论自圆其说。** 质证时应把待验证的声明拆出来，在干净上下文里（不带 LLM 的原推理）单独丢给 NLM，避免污染。
  - **Factored 变体 = 一条结论一个独立 query**，不要把多条结论塞进一个综合质证问题，否则相互污染。这条可以写进质证工序的硬规则。

---

## 6. 综述论文：通用 pipeline 与评估指标

### 6a. Guo, Schlichtkrull, Vlachos — A Survey on Automated Fact-Checking（2022, TACL）
- **来源**：arXiv:2108.11896 — https://arxiv.org/abs/2108.11896
- **统一四阶段 pipeline**（已在第 0 节给出）：Claim Detection → Evidence Retrieval → Verdict Prediction → Justification Production。
- **裁决标签体系的全谱（重要对照）**：
  - **二分类**：True/False（早期），Supported/Refuted（基于证据时）。
  - **三分类**：Support / Refute / Not Enough Information（FEVER 标准）。
  - **多分类真伪刻度**（新闻业常用）："true, mostly-true, mixture" 等程度标签；LIAR 数据集 6 类（pants-on-fire 到 true）；X-Fact 7 类；MultiFC 跨源 2–27 类不等。
  - 作者明确指出：**多源真伪标签难以映射到同一刻度，他们没有强行统一。** 这对可万是个警告：标签体系不要无限细化，够用就好。
- **借鉴点**：可万的 direct/indirect/no_data/source_conflict 四标签，介于"三分类"和"多分类"之间，是合理粒度。但 indirect 这一档在学术界没有直接对应物，需要明确它的判定标准（见下文最值得借鉴第 1 点）。

### 6b. A Survey on Hallucination in Large Language Models（2023）
- **来源**：arXiv:2311.05232 — https://arxiv.org/abs/2311.05232 ｜ HTML: https://arxiv.org/html/2311.05232v2
- **幻觉类型双层 taxonomy**：
  - **Factuality Hallucination（事实性幻觉）**：与真实世界不符。又分 Factual Contradiction（事实矛盾：实体错 / 关系错）和 Factual Fabrication（事实捏造：不可验证 / 过度声称 overclaim）。
  - **Faithfulness Hallucination（忠实性幻觉）**：偏离用户输入或自相矛盾。分 Instruction / Context / Logical Inconsistency。
- **检测方法 taxonomy**：①外部检索核查 ②内部参数知识核查 ③不确定性估计（token 概率/熵）④一致性/采样法（如 SelfCheckGPT：采样多个回答看是否自相一致）⑤LLM-as-judge。
- **借鉴点**：可万的工作流主攻 **factuality hallucination + 外部检索核查（NLM = 外部源）**，这是最可靠的一路。但可以补一条廉价的**一致性检查**：同一个结论让 LLM 多次复述，若每次说法不一致，说明它在 fabricate，优先送 NLM 质证。"overclaim（过度声称）"这个子类值得加进错误模式清单——AI 常把"有迹象表明"说成"证明了"。

---

## 7. Claim 拆解 / 充分性 / check-worthiness 专项

### 7a. FActScore（原子事实拆解的奠基方法）
- **作者/年份**：Min, Krishna, ... Hajishirzi（UW/Allen AI），2023（EMNLP）
- **来源**：arXiv:2305.14251 — https://arxiv.org/abs/2305.14251 ｜ 代码: https://github.com/shmsw25/factscore
- **核心机制**：
  - **原子事实定义**："a short sentence conveying one piece of information（传达单一信息的短句）"，是比句子更基本的单元。
  - **拆解**：先按句切分，每句再喂给 LLM 拆成原子事实；人工复核会再拆分/合并（论文报告专家在 18% 情况下拆分、34% 情况下合并自动结果——说明**拆解粒度本身需要人审，机器拆的不可全信**）。
  - **FActScore = 被可靠知识源支持的原子事实占比**。每条原子事实先从知识源（限定到主题实体的 Wikipedia 页）检索段落，再让评估 LM 判 "[atomic-fact] True or False?"。人工标注用三档：**Supported / Not-supported / Irrelevant**。
- **借鉴点**：**"一条原子事实 = 一个单一信息单元"是 claim 拆解粒度的黄金标准。** 可万从 AI 结论里抽声明时，应拆到"一句一个事实点"，复合句（含多个事实）必须拆开分别质证。这直接对治"复杂声明蒙混过关"。

### 7b. Check-worthiness（哪些声明值得核查）
- **来源**：Claim Detection Survey, arXiv:2401.11969 — https://arxiv.org/abs/2401.11969 ｜ CLEF CheckThat! Lab: arXiv:2109.12987 ｜ ClaimBuster 范式
- **核心机制**：
  - 核查资源有限，"验证所有断言不现实，必须做优先级排序（prioritization）"。Claim detection 分三类子任务：**Verifiability（是否可验证）/ Priority（是否值得花资源 = check-worthiness）/ Similarity（是否和已核查过的声明重复）**。
  - ClaimBuster 把句子分三档：**factual claim / unimportant factual claim / non-factual claim**。
  - check-worthiness 的判定维度：可验证性、流行度/传播度、公共利益、社会影响、时效性、危害性。
- **借鉴点**：**可万工作流缺一个"质证前的分诊（triage）"步骤。** 不是 AI 的每句话都值得送 NLM 质证。先分诊：① 这是可验证的事实声明吗（剔除观点/过渡句 = irrelevant）② 它重要吗（错了会不会影响结论）③ 它是不是高风险（小众数据、易被 fabricate 的具体数字）。把质证算力集中在高 check-worthiness 的声明上。

### 7c. AVeriTeC（2023 最新真实世界范式，标签体系与可万高度对齐）
- **作者/年份**：Schlichtkrull, Guo, Vlachos，2023（NeurIPS Datasets & Benchmarks）
- **来源**：arXiv:2305.13117 — https://arxiv.org/abs/2305.13117 ｜ https://fever.ai/dataset/averitec.html
- **核心机制**：4,568 条真实世界声明（来自 50 家核查机构）。**关键创新：把证据检索建模成"生成问题 + 回答问题"的 QA 对**——每条声明配一组 question-answer pair（带在线证据）+ 文字理据说明证据如何组合出裁决。刻意规避三个坑：context dependence（脱离上下文）、evidence insufficiency（证据不足）、temporal leakage（时间泄漏）。
- **四标签裁决体系**：**Supported / Refuted / Not Enough Evidence / Conflicting Evidence (Cherry-picking)**。
- **借鉴点（这是与可万工作流对应度最高的一篇）**：
  - **AVeriTeC 的四标签和可万的四标签几乎一一对应**：Supported ≈ direct，Refuted ≈（结论被反驳），Not Enough Evidence ≈ no_data，**Conflicting Evidence ≈ source_conflict**。说明可万的标签设计和学术界 2023 年的最新真实世界范式独立收敛了，方向是对的。
  - **"Cherry-picking（选择性引用）"这个限定词值得吸收进 source_conflict**：源冲突不只是"两个源打架"，还包括"AI 只挑了支持它的源、回避了反驳的源"。这是个比"source_conflict"更隐蔽的错误模式，建议补进清单。
  - **QA 对建模证据**（呼应 RARR 的 CQGen 和 CoVe 的验证问题）：把"质证一条声明"统一成"针对它生成问题 → 用源回答 → 由答案组合出裁决"，三篇论文殊途同归，是学术界公认的最佳结构。

---

## 【最值得借鉴的 3 个点】

**第 1 点：补齐"质证前分诊（check-worthiness triage）+ 原子化拆解 + 自包含改写"的前置工序，这是工作流目前最薄弱的一环。**
学术界标准 pipeline 的第一阶段（claim detection）可万几乎是空的。具体三步：① 分诊——不是 AI 的每句话都送 NLM，先用 check-worthiness 维度（可验证性、重要性、高风险性如具体数字/小众数据）筛掉观点句、过渡句、无关句（SAFE 和 FActScore 都设了 irrelevant 档）。② 原子化——按 FActScore 的"一句一个单一信息点"把复合结论拆开，复合声明绝不整条质证。③ 自包含改写——按 SAFE 的 decontextualization，把声明里的代词/省略主语补全，让它脱离 AI 原文也能独立成立。这三步直接对治"复杂声明蒙混"和"质证半截句子"。

**第 2 点：把"质证"重构成"针对声明生成查证问题 → 在干净上下文里用源回答 → 由答案组合出裁决"，并强制单条声明独立质证。**
RARR（CQGen 覆盖所有方面）、CoVe（独立作答防自我污染）、AVeriTeC（QA 对建模证据）三篇独立收敛到同一个结构。对可万的直接改造：质证时**不要把 LLM 的原结论+原推理一起丢给 NLM**（CoVe 证明这会让模型顺着原结论自圆其说，是"诱导性提问"的根源）。正确做法是把每条原子声明单独拎出来，在不含 LLM 推理的干净上下文里向 NLM 提问，一条声明一个独立 query（CoVe 的 Factored 变体效果最好）。这是对"诱导性提问"和"单源依赖"两个错误模式的根本性修复。

**第 3 点：引入 ALCE 的"引用 recall + precision"双指标和 AVeriTeC 的"Cherry-picking"概念，量化和细化现有的置信度/source_conflict 标签。**
现在的置信度是定性的（direct/indirect…）。可以加两个可计算的量化轴：**引用召回**（是否每条结论都挂了能蕴含它的原文引用——管"漏挂"）和**引用精确度**（用 ALCE 的"冗余引用两条件法"自检：去掉某条引用结论还成立、且它单独又撑不住，就删掉——管"凑数引用堆出假有据"，这正是"把综合当证据"的量化检测）。同时把 source_conflict 细化出"Cherry-picking（AI 选择性只引支持它的源、回避反驳源）"这个子类，它比普通的源冲突更隐蔽、危害更大，应单列进错误模式清单。另外建议给 indirect 这一档定义明确判定标准（学术界无直接对应物）：建议定义为"源未直接蕴含结论，但结论是从源的多条信息合理推断得出"，并强制要求标出推断链路，否则容易滑向"把综合当证据"。
