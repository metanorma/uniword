# Bug 03: xmlns:dcmitype not declared in round-tripped core.xml

## Severity: FIXED

## Summary

~~When `CoreProperties` is parsed from an existing DOCX and then re-serialized, the `xmlns:dcmitype` namespace declaration was missing from the output.~~

**Status: Fixed for core.xml.** The reconciler (commit `e48c309`) now rebuilds CoreProperties from scratch:

```ruby
# Reconciler#reconcile_core_properties (lines 308-319)
old_cp = package.core_properties
if old_cp
  package.core_properties = Ooxml::CoreProperties.new(
    title: old_cp.title,
    subject: old_cp.subject,
    # ... all fields copied
  )
end
```

Fresh `CoreProperties.new(...)` correctly applies all `namespace_scope` declarations (xmlns:dc, xmlns:dcterms, xmlns:dcmitype, xmlns:xsi).

## Remaining concern

The underlying lutaml-model behavior persists for OTHER model classes. When objects are parsed from XML, lutaml-model preserves the source namespaces and does NOT apply class-level `namespace_scope` declarations with `declare: :always`. This means:

- `DocumentRoot` parsed from a simple document → only preserves original 3-4 namespaces, not all 35 from `namespace_scope`
- `Settings`, `FontTable`, `StylesConfiguration`, `WebSettings` parsed from simple documents → similarly affected

The core.xml fix works by creating a fresh object. The same pattern could be applied to other parts if needed, but for round-tripped documents that already have proper namespaces from the source, this isn't an issue.

## Verification

```ruby
# Fresh object — works
cp = Uniword::Ooxml::CoreProperties.new
xml = cp.to_xml(prefix: true)
xml.include?("xmlns:dcmitype")  # => true

# After reconciler rebuild — also works
doc = Uniword.load("test.docx")
doc.save("output.docx")
# core.xml now has xmlns:dcmitype
```
