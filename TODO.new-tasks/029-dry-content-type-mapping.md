# 029: DRY content type / part name mapping between package_structure and package_defaults

## Status: DEFERRED

## Problem

The mapping of part names to content types is defined in two places:

1. `PackageStructure#content_type_overrides_for_present_parts` (package_structure.rb:270)
   — Array of `[obj, part_name, content_type]` tuples
2. `PackageDefaults::ClassMethods#minimal_content_types` (package_defaults.rb)
   — Inline `ContentTypes::Override.new(part_name: ..., content_type: ...)`

If a content type string changes, both must be updated. The part names
(`/word/styles.xml`, `/word/settings.xml`, etc.) are also duplicated in
`PackageSerialization#inject_*` methods.

## Fix

Extract a shared `Ooxml::PartRegistry` that maps part targets to their
content types and relationship types:

```ruby
module Uniword::Ooxml::PartRegistry
  PARTS = {
    styles: {
      target: "styles.xml",
      path: "/word/styles.xml",
      content_type: "...styles+xml",
      rel_type: ".../relationships/styles",
    },
    settings: { ... },
    # ... etc
  }.freeze
end
```

Both `content_type_overrides_for_present_parts` and `minimal_content_types`
would use this single source of truth.

This is the first step toward TODO 024 (full OOXML constants extraction).

## Files
- `lib/uniword/ooxml/part_registry.rb` (new)
- `lib/uniword/docx/reconciler/package_structure.rb`
- `lib/uniword/docx/package_defaults.rb`
