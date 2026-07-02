# 12 — Remove `instance_variable_get` from reconciler_spec

**Priority:** High (implementation coupling)
**Files:** `spec/uniword/docx/reconciler_spec.rb`

## Problem

`reconciler_spec.rb:756` reaches into internal state:

```ruby
r10_fixes = described_class.new(package).instance_variable_get(:@applied_fixes)
```

This couples the spec to the ivar name. If the ivar is renamed (e.g.,
during a refactor to `@audit_trail`), the spec silently breaks — the
`instance_variable_get` returns nil instead of raising.

Also note the spec instantiates a SECOND `described_class.new(package)`
just to read the ivar — that's a smell. The reconciler that did the
work is the one whose audit trail we want.

## Root cause

Likely written before `Reconciler#applied_fixes` public reader existed.
The reader is already public (`reconciler.rb:101`):

```ruby
attr_reader :applied_fixes
```

## Fix

Use the public reader:

```ruby
reconciler = described_class.new(package)
reconciler.reconcile
r10_fixes = reconciler.applied_fixes.select { |f| f[:validity_rule] == "R10" }
```

Or just inline the assertion against the reconciler's own audit trail.

### Verification

Spec passes unchanged after the edit. Search for any other
`instance_variable_get` in spec/ and fix similarly.
