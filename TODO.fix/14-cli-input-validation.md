# 14 — Typos in option values silently no-op; bad regexes surface as "Unexpected error"

## Problem
Three input-validation gaps found by probing:

1. `uniword find-replace in.docx out.docx A B --scope bogus` exits
   **0** and prints "Replaced 0 match(es)" — a typo'd or unknown
   scope name is silently skipped, so scripted replacements can
   appear to succeed while doing nothing.
2. `uniword check doc.docx --type bogus` exits **0** with completely
   empty output — neither checker matches the string, so nothing
   runs and nothing is reported.
3. `uniword find-replace in.docx out.docx "[" "y" --regex` reports
   `Unexpected error: premature end of char-class: /[/` — a
   user-input error surfaced through the generic StandardError
   rescue instead of a validation message.

## Fix
- find-replace: validate requested scopes against the engine's
  registered scope names; error with the list of valid scopes,
  exit 1. Pre-validate `--regex` patterns with a friendly
  "Invalid regular expression" message.
- check: validate `--type` against all/quality/accessibility;
  error listing valid values, exit 1.
- redact: same regex pre-validation for `--patterns`.

## Status
IMPLEMENTED — lib/uniword/cli/main.rb (find_replace, check, redact);
specs: spec/uniword/cli_input_validation_spec.rb (Open3: exit 1 +
friendly message for each case; valid values still work).
