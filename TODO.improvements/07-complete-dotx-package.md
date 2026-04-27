# 07: Complete DotxPackage stubs (fontTable, settings, etc.)

**Priority:** P1
**Effort:** Medium (~4 hours)
**File:** `lib/uniword/ooxml/dotx_package.rb`

## Problem

`DotxPackage` has 5 TODO stubs indicating unimplemented .dotx parsing. When
a `.dotx` template is imported (e.g., via `styleset import`), these parts are
not read, making imported StyleSets incomplete.

### Missing parts

| TODO Location | Missing Feature |
|--------------|-----------------|
| Line 39 | `fontTable` lutaml-model attributes |
| Line 103-104 | Parse `fontTable.xml`, `settings.xml`, `webSettings.xml` |
| Line 198-199 | Serialize `fontTable.xml`, `settings.xml`, `webSettings.xml` |
| Line 104 | Parse relationships and content types |
| Line 199 | Serialize relationships and content types |

The existing `Docx::Package` (`lib/uniword/docx/package.rb`) already parses
all of these parts. The fix is to bring `DotxPackage` to parity with
`Docx::Package` for shared parts.

## Fix

1. **Read the parts** (in `initialize` or parse method, ~line 103):

```ruby
# Parse fontTable.xml
if entry = find_entry("word/fontTable.xml")
  self.font_table = Wordprocessingml::FontTable.from_xml(read_entry(entry))
end

# Parse settings.xml
if entry = find_entry("word/settings.xml")
  self.settings = Wordprocessingml::Settings.from_xml(read_entry(entry))
end

# Parse webSettings.xml
if entry = find_entry("word/webSettings.xml")
  self.web_settings = Wordprocessingml::WebSettings.from_xml(read_entry(entry))
end

# Parse relationships
if entry = find_entry("_rels/.rels")
  self.package_rels = Relationships::Relationships.from_xml(read_entry(entry))
end

# Parse content types
if entry = find_entry("[Content_Types].xml")
  self.content_types = ContentTypes::Types.from_xml(read_entry(entry))
end
```

2. **Write the parts** (in serialize method, ~line 198): Mirror the read
   logic for writing.

3. **Add attributes**: Declare `font_table`, `settings`, `web_settings`,
   `package_rels`, `content_types` as lutaml-model attributes (or plain
   accessors if they're package-level, not XML-mapped).

Reference `Docx::Package` for the exact implementation pattern.

## Verification

```bash
# Import a .dotx file and verify all parts are preserved
bundle exec rspec spec/uniword/stylesets/
bundle exec rspec spec/integration/  # round-trip tests
```
