---
name: vkskill-source
description: |
  Find evidence and gather sources. Trigger on "找证据", "搜证", "找材料", "gather sources", "find evidence", "collect sources", or when the user gives URLs and wants original text saved locally and loaded into NotebookLM.
---

# vkskill-source

Find sources, preserve original text, and load sources into NotebookLM.

## When Starting

If the user gave URLs, skip search and capture those URLs.

If the user gave a topic, search for sources.

If the user only said "找证据" or "搜证", ask:

> 你要找什么方向的材料？有具体链接吗？

## Source Selection

Use available web search and browser tools. Prefer primary sources:

- official documents
- original papers
- author posts
- government or court records
- company filings

Read `../vkskill-proof/references/source-grading.md` before grading sources.

## Capture Waterfall

For every selected URL:

1. Create `raw/original/` and `raw/extracted/`.
2. Save the original response to `raw/original/`.
3. Extract readable text to `raw/extracted/`.
4. If curl fails or the page is JS-rendered, use an available browser tool or Playwright.
5. If capture still fails, append the URL and reason to `raw/00-unfetched-sources.md`.

Use this metadata header for extracted files:

```markdown
---
source: [original URL]
captured: [date]
method: curl+textutil | browser | manual
note: extracted text, not the original file
---
```

## NotebookLM Loading

For each source:

1. Try `source_add(source_type=url, url=URL)`.
2. If URL loading fails, use `source_add(source_type=file, file_path="raw/extracted/xxx.md")`.
3. Report sources that failed both paths.

## Output

Return a short source report:

- selected sources
- source grade
- capture method
- NotebookLM load status
- known gaps
