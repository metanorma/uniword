# 014: Replace `attr_accessor :header_footer_parts` with model-driven attribute

## Status: COMPLETED via TODO.validate/09

`header_footer_parts` is now a `Docx::HeaderFooterPartCollection` of
`HeaderFooterPart` value objects (r_id, target, rel_type, content_type,
type, content, loaded flag — no more hashes with symbol keys).
`chart_parts` and `embeddings` hold `Docx::Part`/`ChartPart` objects in
`Docx::PartCollection`s; `custom_xml_items` holds `CustomXmlItem` objects
(Package writers still accept legacy hashes and normalize them).
`bibliography_sources` was already a `Bibliography::Sources`
Serializable. `raw_xml_parts` and `modified_part_paths` remain plain
serialization-level accessors as this note recommended.

## Problem

`DocumentRoot` uses `attr_accessor :header_footer_parts` (line 103) instead
of a lutaml-model `attribute` declaration. This breaks the model-driven
architecture principle — all document parts should be declared as attributes
so they participate in serialization, equality, and cloning.

Similarly, `Package` uses `attr_accessor` for several non-serialized helpers:
- `chart_parts` (line 89)
- `bibliography_sources` (line 89)
- `profile` (line 89)
- `raw_xml_parts` (line 94)
- `modified_part_paths` (line 97)
- `custom_xml_items` (line 50)

## Fix

### For `header_footer_parts` on DocumentRoot

Replace with a proper attribute declaration. The "parts" are hashes with
`:content` being a Header/Footer model — define a dedicated model class:

```ruby
class HeaderFooterPart < Lutaml::Model::Serializable
  attribute :r_id, :string
  attribute :target, :string
  attribute :rel_type, :string
  attribute :content_type, :string
  attribute :content, Header # or Footer — polymorphic
end
```

This enables:
- Model-driven serialization instead of manual hash manipulation
- Type safety (no more hash with symbol keys)
- Proper OOP (behavior lives on the object, not on callers)

### For Package helpers

`raw_xml_parts` and `modified_part_paths` are serialization-level
implementation details — they should stay as `attr_accessor`. But
`chart_parts`, `bibliography_sources`, and `custom_xml_items` should be
proper model attributes or dedicated model classes.

## Files
- `lib/uniword/wordprocessingml/document_root.rb` (line 103)
- `lib/uniword/docx/package.rb` (lines 50, 89-97)
