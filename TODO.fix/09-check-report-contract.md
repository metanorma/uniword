# 09 — `check`: report-contract mismatch crashes every non-trivial invocation

## Problem
The `check FILE` task assumes a report API that does not exist:

1. `Accessibility::AccessibilityReport` has `compliant?` / `violations`,
   but the task calls `valid?` on it (`display_check_reports`,
   `reports.transform_values { |r| r.valid? }`). Result:
   `uniword check FILE` and `--type accessibility` both crash with
   `undefined method 'valid?'` AFTER quality results print, exiting 1
   on a perfectly clean document.
2. The task branches on `Uniword::Quality::CheckReport`, a class that
   does not exist — `DocumentChecker#check` returns
   `Quality::QualityReport`. Any path that reaches the `is_a?`
   (`check --type quality --json`, or displaying a failing quality
   report) raises `NameError: uninitialized constant
   Uniword::Quality::CheckReport`, also swallowed into exit 1.
3. Because the `is_a?` was always false, `--json` reported
   `issues: 0` for failing quality reports, non-JSON display showed
   `? issue(s) found`, and `--verbose` never listed any issue — for
   BOTH report types.
4. `check` exited 0 even when error-level findings existed —
   inconsistent with `spellcheck check` (exit 1 on findings) and
   `validate` (exit 1 on error issues), so CI/pipelines could not
   gate on it.

Root cause: the two report classes (`QualityReport`,
`AccessibilityReport`) share an implicit contract (`violations`,
`add_violation`, error/warning/info partitioning) but only
`QualityReport` has `valid?`, and the CLI invented a third class
(`CheckReport`) plus an `issues` accessor that never existed.

## Fix
- `AccessibilityReport`: add `valid?` (delegates to `compliant?`,
  true when no error-level violations) — the one missing member of
  the shared contract.
- `cli/main.rb#check` + `display_check_reports`: use the contract
  both classes actually implement — `report.valid?` and
  `report.violations` — uniformly for both types. No `is_a?`
  branching, no phantom `CheckReport` constant.
- `--verbose` prints `violation.message` for every finding of both
  checkers (both violation classes expose `message`).
- Exit 1 when any report has error-level findings (warnings/info
  still exit 0), matching the spellcheck/validate exit contract.

## Status
IMPLEMENTED — lib/uniword/cli/main.rb (check, display_check_reports);
lib/uniword/accessibility/accessibility_report.rb (valid?);
specs: spec/uniword/cli_check_report_contract_spec.rb.
