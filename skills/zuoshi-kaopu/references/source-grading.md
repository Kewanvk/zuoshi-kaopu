# Source Grading

## Quick Classification

| Grade | Source Type | Examples | Usage Rule |
|-------|-----------|----------|------------|
| A | Primary official documents | Annual reports, government filings, court records, SEC filings | Use directly |
| B | Official websites / self-declarations | Company website bios, LinkedIn profiles, personal statements | Use directly, but note: self-declarations about own strengths carry bias |
| C | Third-party databases | Bloomberg profiles, Crunchbase, industry databases | Cross-verify with one other source |
| D | News / secondary reporting | Media articles, Wikipedia, press releases | Cross-verify with two other sources |
| X | Inference / assumption | Guessing from surname, appearance, or indirect signals | Never use. Mark "no public source" |

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
