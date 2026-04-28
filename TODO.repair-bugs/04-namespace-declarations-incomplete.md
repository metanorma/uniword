# Bug 04: Multiple DOCX parts missing expanded namespace declarations

## Severity: FIXED

## Summary

Multiple DOCX XML parts were missing required namespace declarations that Word expects. The `mc:Ignorable` attribute is now correctly set by the Reconciler, and all `declare: :always` namespace scopes now take full effect on round-tripped documents.

## What was fixed

### Fix 1: `mc:Ignorable` + namespace_scope declarations (commit `e48c309` + `0be834f`)

- All model classes (`DocumentRoot`, `Settings`, `FontTable`, `StylesConfiguration`, `WebSettings`) now have `namespace_scope` defined with all required Word 2010-2024 namespaces
- Reconciler sets `mc:Ignorable` on all parts when profile is present

### Fix 2: Profile defaults for loaded packages

`Package#to_zip_content` now falls back to `Profile.defaults` when profile is nil, ensuring the Reconciler's Group 2 always runs even for packages loaded via `from_file`.

### Fix 3: Clear stored namespace plans (this commit)

For parsed objects, lutaml-model stores a `pending_namespace_data` (declaration plan) from the source XML that takes precedence during serialization. This meant a simple document with only 3-4 namespaces would never gain the full 35-namespace set from `declare: :always` scopes.

The Reconciler now clears `pending_namespace_data` and `import_declaration_plan` on all serialized model parts before serialization, so `declare: :always` namespace scopes take full effect.

## Result

```
hello-world-bad.docx round-trip (was 4 namespaces, now full set):
  document.xml:  35 namespaces, mc:Ignorable=true
  settings.xml:  17 namespaces, mc:Ignorable=true
  styles.xml:    12 namespaces, mc:Ignorable=true
  fontTable.xml: 12 namespaces, mc:Ignorable=true
  webSettings:   12 namespaces, mc:Ignorable=true
  core.xml:       5 namespaces (including xmlns:dcmitype)
```
