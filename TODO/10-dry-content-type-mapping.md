# 029: DRY content type / part name mapping between package_structure and package_defaults

## Status: COMPLETED via TODO.validate/08

Implemented as `Uniword::Ooxml::PartRegistry` (TODO.validate item 08),
with proper `PartDefinition` model objects instead of a raw hash.
`PackageStructure#content_type_overrides_for_present_parts` and
`PackageDefaults#minimal_content_types` (plus `ContentTypes.generate`
and the `PackageSerialization` `inject_*` methods) all derive part
names, content types, and relationship types from the single registry.

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
