# 025: Remove dead code in Reconciler::PackageStructure

## Status: DONE

## Problem

`PackageStructure` contains a `valid_document_rel?` method (lines 271-275)
that is never called from anywhere:

```ruby
def valid_document_rel?(rel)
  return false if package_level_rel?(rel.type)
  return false unless header_footer_target_present?(rel[:target] || rel.target)
  true
end
```

It references `rel[:target]` (symbol key access on a model object) which
would likely fail at runtime — model objects use `rel.target` not `rel[:target]`.

## Fix

Remove `valid_document_rel?` — it's dead code with a potential bug.

## Files
- `lib/uniword/docx/reconciler/package_structure.rb` (lines 271-275)
