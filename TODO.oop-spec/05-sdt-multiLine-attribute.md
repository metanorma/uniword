# 05-sdt-multiLine-attribute.md

# Fix: SdtText missing multiLine attribute

## Problem
The `SdtText` (or `Text`) class in the structured_document_tag directory has no attribute mappings.
The `multiLine` attribute on `<w:text>` elements is lost during round-trip.

## Fix

### File: `lib/uniword/wordprocessingml/structured_document_tag/text.rb`

```ruby
attribute :multi_line, :string

xml do
  element 'text'
  namespace Ooxml::Namespaces::WordProcessingML
  map_attribute 'multiLine', to: :multi_line
end
```

## Verification
```bash
bundle exec rspec spec/integration/docx_roundtrip_spec.rb:138
```
