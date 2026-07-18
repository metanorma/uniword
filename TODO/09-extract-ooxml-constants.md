# 024: Extract OOXML constants into dedicated module

## Status: COMPLETED via TODO.validate/08

Superseded by `Uniword::Ooxml::PartRegistry` (TODO.validate item 08):
all part metadata — content types, relationship type URIs, part paths —
now lives in `lib/uniword/ooxml/part_registry.rb` as `PartDefinition`
entries. `IdAllocator`, `Reconciler::Body`, the image/chart/bibliography
builders, `Hyperlink`, and `Docx::Package` derive their constants from
the registry instead of duplicating literals. Remaining literal sites
(read-path fragment matchers, validation namespace URIs, the
stylesWithEffects filter) are documented exceptions in the item 08
completion notes.

## Problem

OOXML content type strings, relationship type URIs, and part names are
scattered as inline string literals across the codebase:

- **Content type strings** (e.g., `"...wordprocessingml.header+xml"`) appear
  in `package.rb`, `package_serialization.rb`, and `package_structure.rb`.
- **Relationship type URIs** (e.g., `".../relationships/header"`) appear in
  `body.rb`, `hyperlink.rb`, `image_builder.rb`, `id_allocator.rb`,
  `package_serialization.rb`, and `package_defaults.rb`.
- **Part names** (e.g., `"/word/styles.xml"`, `"styles.xml"`) appear in
  `package_structure.rb`, `package_defaults.rb`, and `package_serialization.rb`.

The base URI `"http://schemas.openxmlformats.org"` is reconstructed in
multiple places (`package_structure.rb`, `package_defaults.rb`).

`IdAllocator` already defines some of these as constants (REL_TYPE_BASE,
HEADER_REL_TYPE, etc.) but they're not shared with other files.

## Fix

Create `Uniword::Ooxml::Constants` with all part metadata:

```ruby
module Uniword::Ooxml::Constants
  BASE_URI = "http://schemas.openxmlformats.org"
  REL_BASE = "#{BASE_URI}/officeDocument/2006/relationships"

  module Relationships
    HEADER   = "#{REL_BASE}/header"
    FOOTER   = "#{REL_BASE}/footer"
    IMAGE    = "#{REL_BASE}/image"
    THEME    = "#{REL_BASE}/theme"
    STYLES   = "#{REL_BASE}/styles"
    # ... etc
  end

  module ContentTypes
    HEADER = "application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml"
    FOOTER = "application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"
    # ... etc
  end

  module PartNames
    STYLES    = "styles.xml"
    SETTINGS  = "settings.xml"
    FONT_TABLE = "fontTable.xml"
    # ... etc
  end
end
```

This follows the Open/Closed Principle — adding a new part type requires
only adding constants, not searching the codebase for string literals.

## Files
- `lib/uniword/ooxml/constants.rb` (new)
- `lib/uniword/docx/reconciler/body.rb`
- `lib/uniword/docx/reconciler/package_structure.rb`
- `lib/uniword/docx/package.rb`
- `lib/uniword/docx/package_serialization.rb`
- `lib/uniword/docx/package_defaults.rb`
- `lib/uniword/hyperlink.rb`
- `lib/uniword/builder/image_builder.rb`
- `lib/uniword/docx/id_allocator.rb`
