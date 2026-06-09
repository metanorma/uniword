# 013: DRY up package part injection in PackageSerialization

## Status: DONE

## Problem

The `inject_*` methods in `PackageSerialization` follow a near-identical
pattern:

```ruby
def inject_<part>(content_types, document_rels)
  return unless <condition>

  unless content_types.overrides.any? { |o| o.part_name == "<path>" }
    content_types.overrides << ContentTypes::Override.new(
      part_name: "<path>", content_type: "<type>"
    )
  end

  return if document_rels.relationships.any? { |r| r.target == "<target>" }

  document_rels.relationships << Relationship.new(
    id: next_rid(document_rels), type: "<rel_type>", target: "<target>"
  )
end
```

This pattern repeats 7 times (notes, theme, numbering, bibliography,
custom_properties, charts, header_footer_parts). Each variant differs only
in the condition, part name, content type, relationship type, and target.

## Fix

Extract a shared `ensure_part_registered` method:

```ruby
def ensure_part_registered(content_types, document_rels, part_name:,
                           content_type:, rel_type:, target:)
  unless content_types.overrides.any? { |o| o.part_name == part_name }
    content_types.overrides << ContentTypes::Override.new(
      part_name: part_name, content_type: content_type
    )
  end

  return if document_rels.relationships.any? { |r| r.target == target }

  document_rels.relationships << Relationship.new(
    id: next_rid(document_rels), type: rel_type, target: target
  )
end
```

Then each `inject_*` becomes:

```ruby
def inject_theme(content_types, document_rels)
  return unless theme

  ensure_part_registered(content_types, document_rels,
    part_name: "/word/theme/theme1.xml",
    content_type: "application/vnd.openxmlformats-officedocument.theme+xml",
    rel_type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme",
    target: "theme/theme1.xml"
  )
end
```

This follows the Open/Closed Principle — adding a new part type requires
only a new `inject_*` one-liner, not copy-pasting the full pattern.

## Files
- `lib/uniword/docx/package_serialization.rb` (lines 158-420)
