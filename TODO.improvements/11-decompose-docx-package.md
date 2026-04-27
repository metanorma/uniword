# 11: Decompose Docx::Package (1019 lines)

**Priority:** P2
**Effort:** Medium (~4 hours)
**File:** `lib/uniword/docx/package.rb`

## Problem

`Docx::Package` is both a data model (extends `Lutaml::Model::Serializable`)
and a service (has `from_file`, `to_file`, `extract_image_parts`). At 1019
lines, it mixes concerns:

| Responsibility | Lines |
|---------------|-------|
| Model attributes (lutaml-model) | ~200 |
| File I/O (from_file, to_file) | ~200 |
| Part extraction (images, styles, etc.) | ~300 |
| Serialization (XML parts) | ~200 |
| Utility methods | ~100 |

## Fix

Extract service methods into a `PackageIO` module:

```
lib/uniword/docx/
  package.rb          # Model class only (~400 lines)
  package_io.rb       # from_file, to_file, extract_* (~400 lines)
  package_builder.rb  # Construction helpers (~200 lines)
```

`Package` includes `PackageIO` for backward compatibility:

```ruby
class Package < Lutaml::Model::Serializable
  include PackageIO

  # lutaml-model attributes only
  attribute :document, ...
  attribute :styles, ...
  # etc.
end
```

Alternatively, use composition: `Package` is pure model, and a `PackageReader`
/ `PackageWriter` handle I/O. This is cleaner but requires updating callers.

## Verification

```bash
bundle exec rspec spec/uniword/docx/
bundle exec rspec spec/integration/  # all round-trip tests
```
