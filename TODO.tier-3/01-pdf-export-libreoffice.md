# 01 — PDF export (LibreOffice bridge)

**Status:** PLANNED (Tier 3)
**Priority:** High impact but heavy runtime dep
**Depends on:** nothing

## Why

Every document pipeline ends in PDF. Without PDF output, uniword
can be the start of a pipeline but never the end. LibreOffice is
already a runtime dep in tests; productionize it.

## Approach

Wrap `soffice --headless --convert-to pdf`. CLI: `uniword convert
input.docx output.pdf`.

## Why Tier 3

- Adds LibreOffice as a runtime dep (300+ MB on Linux)
- Slow first-run (LibreOffice startup)
- Native PDF writer (Tier 3/03) supersedes it eventually
- Better as a separate optional gem: `uniword-pdf-libreoffice`

## When to promote

When users start asking "how do I get PDF out?" frequently enough
that the missing-capability support burden exceeds the engineering
cost of shipping the bridge.
