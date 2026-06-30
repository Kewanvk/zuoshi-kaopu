# Common Error Patterns

Eight error patterns observed in real research tasks. Review before starting
any verification pass.

## 1. Keyword Match is not Semantic Match

Finding a word on a page does not mean the page proves what you need.
"Colombia" appearing in a business description ("operations in Colombia")
is not the same as "born in Colombia."

**Prevention:** For every piece of evidence, ask: "Who is the subject of this
sentence? Is it describing this specific entity's own attribute?"

## 2. Automating Judgment Tasks

Some tasks require semantic understanding and cannot be delegated to keyword
matching, regex, or scripts. A script can find where a word appears, but
cannot judge whether that occurrence is relevant evidence.

**Prevention:** Distinguish mechanical operations (can automate) from judgment
operations (must be done semantically). Never automate the judgment layer.

## 3. Filling Data from Memory Instead of Source

Writing data based on what "feels right" without opening the source to confirm.
Example: writing "BS Computer Science" when the actual degree was "Symbolic Systems."

**Prevention:** Every data point must come from the source, never typed from
memory. If you cannot point to the exact source text, you do not have evidence.

## 4. Inferring Identity from Surface Features

Assuming ethnicity from surnames, nationality from appearance, or identity
from indirect signals.

**Prevention:** Without an explicit source, mark "no public source." Never use
surface features to fill identity fields.

## 5. Overconfident Visual Judgment

Making definitive claims about image content when resolution is limited or
details are unclear.

**Prevention:** Be honest about confidence levels for visual content. If
something is unclear, state "cannot verify visually" rather than guessing.

## 6. Non-Traceable Source Citations

Writing vague source labels like "biographical sources" or "inferred from
context" that fill the source field but provide no way for a reader to verify.

**Prevention:** A valid source is a URL, document name + page number, or
specific database entry. If none exists, write "no public source" and state
the reasoning separately.

## 7. Unverified URLs

Recording source URLs without confirming they are accessible. Some URLs return
404, contain encoding errors, or redirect to unrelated content.

**Prevention:** Every URL must be confirmed accessible and content-matching
before inclusion in the final output.

## 8. Superficial Verification

Designing verification checks around "what is easy to check" rather than
"what is most likely to be wrong."

**Prevention:** Start verification from "where are errors most likely?" not
"what is easiest to check?" The most important check is always: does this
evidence actually prove this specific claim?
