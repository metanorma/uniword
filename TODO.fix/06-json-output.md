# 06 — machine-readable output: `--json` on info and validate

## Problem
`check` has `--json`, but `info` and `validate` print human-only text,
so scripts must scrape colored prose. `ValidationReport#to_json`
already exists.

## Fix
- `uniword info FILE --json` — document statistics as JSON
  (same fields as the text output).
- `uniword validate FILE --json` — the ValidationReport JSON
  (existing `to_json`), exit code still 1 when error-level findings.

## Status
IMPLEMENTED — lib/uniword/cli/main.rb;
spec: spec/uniword/cli/json_output_spec.rb.
