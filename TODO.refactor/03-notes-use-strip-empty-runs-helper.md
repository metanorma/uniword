# 03 — Call `strip_empty_runs` helper instead of inline reject! in notes.rb

**Priority:** Critical (lost audit trail)
**Files:** `lib/uniword/docx/reconciler/notes.rb`

## Problem

`notes.rb:180` (inside `ensure_separators`) reimplements the empty-run
rejection inline:

```ruby
entry.paragraphs.each do |p|
  p.runs.reject! { |r| empty_run?(r) }
  ensure_separator_run(p, entry.type)
end
```

This bypasses the `strip_empty_runs` helper at `helpers.rb:126`, which
records an R-fix audit trail entry when runs are removed. As a result,
separator-paragraph cleanup in notes happens "silently" — the applied
fixes log doesn't reflect it.

## Root cause

Likely an oversight during the reconciler modularization. The inline
form was written before `strip_empty_runs` was extracted into Helpers,
and was never updated to call the helper.

## Fix

Replace the inline reject! with the helper:

```ruby
entry.paragraphs.each do |p|
  strip_empty_runs(p)
  ensure_separator_run(p, entry.type)
end
```

### Verification

Existing separator-related specs should continue to pass. Add a spec
asserting that when `ensure_separators` removes an empty run, an
audit-trail entry with the appropriate rule code is recorded.
