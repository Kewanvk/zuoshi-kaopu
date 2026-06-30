# Source Grading

## Quick Classification

| Grade | Source Type | Examples | Usage Rule |
|-------|-----------|----------|------------|
| A | Primary official documents | Annual reports, government filings, court records, SEC filings | Use directly |
| B | Official websites / self-declarations | Company website bios, LinkedIn profiles, personal statements | Use directly, but note: self-declarations about own strengths carry bias |
| C | Third-party databases | Bloomberg profiles, Crunchbase, industry databases | Cross-verify with one other source |
| D | News / secondary reporting | Media articles, Wikipedia, press releases | Cross-verify with two other sources |
| X | Inference / assumption | Guessing from surname, appearance, or indirect signals | Never use. Mark "no public source" |

## Academic Paper Credibility Audit

Before extracting data from any academic paper, run these checks:

### Mandatory (do before citing)

1. **Journal check**: Is the journal on Beall's List or known predatory publisher lists?
   Search: `"[journal name]" predatory OR "beall's list"`. If yes, downgrade to Grade D
   and flag prominently.

2. **Too-good-to-be-true gate**: 100% success rates, zero side effects, or claims
   that one intervention cures everything should trigger extra scrutiny, not acceptance.

3. **Author publication pattern**: Search author name + key terms. If the same team
   claims the same product cures vastly different diseases across species
   (humans + pigs + chickens + dogs + cats + fish), this is a "miracle cure" red flag.

4. **Institution name verification**: Translate institution names back to the original
   language and verify. Do not substitute similar-sounding prestigious names
   (e.g., Tongrun Tang ≠ Tongrentang/同仁堂). This is a factual error, not a
   judgment call.

5. **Ingredient/method disclosure**: If the paper does not disclose the intervention's
   composition (ingredients, dosage, preparation), it cannot be independently
   verified or replicated. Note this as a limitation.

### Red flags (any one = flag the source)

- Published exclusively in low-impact or predatory journals
- No independent replication by other teams
- Authors acknowledge data is from "clinical observations" not controlled trials
- Study subjects obtained through unusual means (e.g., human clinic capturing feral cats)
- Conflicts of interest not disclosed despite commercial product being tested

### Grading override

A paper with DOI and tables but published in a predatory journal should be graded
**D or lower**, not B. "Has DOI" ≠ "credible."

## Important Caveat

Source grade is an initial label, not a final judgment.

A Grade-A source (e.g., an annual report) is generally reliable, but it can
still be unreliable for specific claims. A company's annual report is a good
source for revenue figures but a biased source for competitive positioning.

**Final reliability is assessed at the claim level, not the source level.**
The Claim Ledger's confidence field (direct / indirect / no_data / source_conflict)
is the main indicator, not the source grade alone.

## Citation Specificity

Not all NLM responses are equally usable. Assess each response:

| Response Type | Example | Verdict |
|--------------|---------|---------|
| Exact quote with source ID | "Revenue was $12M" (source: abc123) | Accept as `direct` |
| Paraphrased with source ref | "According to the filing, revenue was $12M" | Accept as `direct`, but re-query for exact quote if possible. Note "paraphrased by NLM" in Claim Ledger |
| Vague attribution | "Based on the sources, revenue appears to be around $12M" | Mark `indirect`, re-query with specific question |
| No source cited | "Revenue was likely $12M based on industry norms" | Reject. This is inference, not evidence |
| Explicit absence | "The provided sources do not mention revenue figures" | Record as `no_data`. Do not fill the gap |
