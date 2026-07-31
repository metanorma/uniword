# 06 — Public demo site

**Status:** PLANNED (Tier 3)
**Priority:** Marketing/eval
**Depends on:** HTTP API (Tier 3/02)

## Why

Lowers the evaluation bar from "install Ruby" to "open a URL".
Upload a docx, see the verification report, download the repaired
copy.

## Approach

Static site + HTTP API backend. Hosted at `try.uniword.dev` or
similar. Rate-limited, file-size-limited, no persistent storage.

## Why Tier 3

Requires hosting infra + security review.
