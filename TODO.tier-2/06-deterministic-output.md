# 06 — Deterministic output mode

**Status:** PLANNED
**Priority:** Medium (git-friendly diffs)
**Depends on:** nothing

## Why

Stable rIds via `IdAllocator` already gives us content-level
determinism. Add XML whitespace, attribute order, and ZIP timestamp
normalization so byte-diff is meaningful for git-tracked documents.

## Scope

- `Configuration#deterministic_output = true`
- XML output: stable attribute order per element (alphabetical or
  schema-order), no insignificant whitespace, consistent quoting
- ZIP output: fixed timestamps (e.g., 1980-01-01), no compression
  level variation, deterministic entry order
- Effective immediately on `doc.save`

## Verification

```bash
uniword convert a.docx a1.docx --deterministic
uniword convert a.docx a2.docx --deterministic
diff <(unzip -p a1.docx word/document.xml) <(unzip -p a2.docx word/document.xml)
# empty diff
```

## Out of scope

- Canonical OOXML (there's no spec for this)
- Byte-identical to Word output (Word isn't deterministic)
