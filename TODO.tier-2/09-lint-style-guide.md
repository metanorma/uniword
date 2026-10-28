# 09 — Lint / style guide enforcement

**Status:** PLANNED
**Priority:** Medium for corporate/government
**Depends on:** nothing

## Why

Beyond `verify`/`validate` (which check OPC correctness), enforce
content rules: "headings use sentence case", "no contractions in
formal docs", "all images have alt text". Configurable YAML ruleset
per organization.

## Scope

- New `uniword lint FILE --ruleset corporate.yml` command
- Rule types:
  - `style`: heading case, voice, contractions
  - `inclusion`: required sections, required metadata
  - `exclusion`: banned words, banned phrases
  - `structure`: max paragraph length, max sentence length
  - `accessibility`: alt text on images, heading hierarchy
- Output: same structured report as `verify`

## Architecture

```
Uniword::Lint
  ├── Engine            # walks document, applies rules
  ├── Rule              # abstract
  │   ├── StyleRule
  │   ├── InclusionRule
  │   ├── ExclusionRule
  │   ├── StructureRule
  │   └── AccessibilityRule
  └── Ruleset           # loaded from YAML
```

## Out of scope

- Grammar checking (use spellcheck + aspell/grammar engines)
- Brand voice ML (out of scope for v1)
