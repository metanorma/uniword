# 10 — Batch operations

**Status:** PLANNED
**Priority:** High for ops/CI
**Depends on:** nothing

## Why

`uniword batch` exists for format conversion. Add batch variants of
repair, verify, find-replace, diff, lint — operate on hundreds of
docs in parallel with structured per-doc reports.

## Scope

- `uniword batch repair '*.docx' --output-dir out/`
- `uniword batch verify '*.docx' --json > report.json`
- `uniword batch find-replace '*.docx' --pattern foo --replacement bar`
- `uniword batch diff --old-dir v1/ --new-dir v2/ --report report.json`
- Parallel execution (default: CPU count)
- Per-doc structured results (JSON/YAML output)
- Exit code: 0 if all succeed, 1 if any fail

## Architecture

```
Uniword::Batch
  ├── Runner            # parallel execution
  ├── Task              # abstract: one operation on one file
  │   ├── RepairTask
  │   ├── VerifyTask
  │   ├── FindReplaceTask
  │   ├── DiffTask
  │   └── LintTask
  └── Report            # aggregated results
```

## Out of scope

- Distributed execution (single machine only)
- Resume from checkpoint (use shell-level job control)
