# Evidence Rules

## Core Principle

LLMs are hypothesis engines. NotebookLM is an evidence engine. The LLM proposes;
NLM verifies with source text. Never reverse this: do not let NLM summarize first
and then have the LLM analyze the summary.

**Correct flow:** LLM forms hypothesis -> asks NLM "is this true? where's the evidence?"
**Wrong flow:** NLM summarizes everything -> LLM picks interesting parts

## Rules

### 1. Source materials over training knowledge

When source documents are available, never fill answers from training data. If
the answer is in the sources, cite it. If it is not, record "no data."

### 2. Audio and recordings always go through NLM

Any audio file (.m4a, .mp3, .wav, .aac) must be uploaded to NLM directly. Never
transcribe locally with whisper, ffmpeg, or any local model. If NLM is
unavailable, stop and report. Do not silently fall back to local transcription.

### 3. PDFs go through NLM by default

Do not extract or summarize PDFs locally. Upload to NLM and query through it.
Exception: user explicitly provides pasted text and asks to work from that.

### 4. Web content must include source URLs

Whether fetched via web tools or agent crawling, the original URL must be
recorded. The URL itself should also be added as an NLM source.

### 5. Ask before uploading sensitive material

Confidential, personal, client, credential, or regulated materials require
explicit user authorization before uploading to NLM.

### 6. Merge crawled fragments before uploading

Scattered data from crawlers (social media comments, forum posts, job listings)
should be merged into a single structured document with an index before
uploading to NLM. Do not upload 100+ individual fragments.

### 7. Separate different evidence types

Keep different categories of evidence in separate notebooks or clearly tagged
batches (e.g., financial filings vs. interview transcripts). This allows
cross-referencing while preserving source attribution.

### 8. Extraction and verification are separate steps

The process that collects candidate conclusions must not be the same process
that verifies them. Run extraction first, then re-query with rephrased
questions for verification.

### 9. NLM's synthesis is not evidence

When NLM answers a query, it may cite source text (evidence) or synthesize
across sources (not evidence). Only quoted source passages count as evidence.
NLM's own summaries and generalizations require the same scrutiny as LLM output.

### 10. Record four fields per conclusion

Every conclusion in the Claim Ledger must have:
- The conclusion itself
- The source quote (exact passage)
- The source identifier (document + location)
- The confidence level (direct / indirect / no_data / source_conflict)

### 11. Absence of evidence is a valid finding

"No data in provided sources" is an honest, useful result. Never turn it into
a guess. Never fill gaps with "likely" or "probably" based on general knowledge.
An empty cell is better than a wrong one.

### 12. Verified conclusions go to file

Conclusions that survive verification are written to markdown files with their
evidence trail. Never keep verified knowledge only in conversation context.
Files are the interface between steps and between sessions.

## Narrow Exceptions

These situations may be handled without NLM:
- Text pasted directly into the conversation by the user
- Short files under a few hundred words
- Code, configuration files, or logs
- Purely mechanical operations (formatting, translation, cleanup) that do not
  require evidence-backed claims
