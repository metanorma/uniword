# Proposal: Add `standalone` Support to `generate_declaration`

## Status: IMPLEMENTED

The fix has been implemented in `lutaml-model-new`.

## Problem

OOXML documents (DOCX, XLSX, PPTX) require `standalone="yes"` in the XML declaration:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
```

Previously, `generate_declaration` in `declaration_handler.rb` only supported `version` and `encoding`. The `standalone` attribute was not extracted from input XML and not included in output.

## Implementation

### Files Modified

- `lib/lutaml/xml/declaration_handler.rb`

### Changes

**1. `extract_xml_declaration` (line 16)**

Added extraction of `standalone` attribute:

```ruby
# Extract standalone (may be absent)
standalone = extract_attribute(decl_content, "standalone")

{
  version: version,
  encoding: encoding,
  standalone: standalone,  # NEW
  had_declaration: true,
}
```

**2. `generate_declaration` (line 128)**

Added standalone generation:

```ruby
# Determine standalone
# Priority: explicit standalone option > input standalone > none
# Supported values: "yes", "no", true ("yes"), false ("no"), :preserve
standalone = if options.key?(:standalone)
               case options[:standalone]
               when String
                 options[:standalone]
               when true
                 "yes"
               when false
                 "no"
               when :preserve
                 xml_declaration&.dig(:standalone)
               end
             elsif xml_declaration&.dig(:standalone)
               xml_declaration[:standalone]
             end

declaration = "<?xml version=\"#{version}\""
declaration += " encoding=\"#{encoding}\"" if encoding
declaration += " standalone=\"#{standalone}\"" if standalone  # NEW
declaration += "?>\n"
```

## Verification

```bash
cd /Users/mulgogi/src/lutaml/lutaml-model-new

# Test standalone extraction
bundle exec ruby -e '
require "lutaml/model"
xml = %(<?xml version="1.0" encoding="UTF-8" standalone="yes"?>)
result = Lutaml::Xml::DeclarationHandler.extract_xml_declaration(xml)
puts result.inspect
# => {:version=>"1.0", :encoding=>"UTF-8", :standalone=>"yes", :had_declaration=>true}
'

# Test standalone round-trip
bundle exec ruby -e '
require "uniword"
doc = Uniword.load("examples/demo_formal_integral_proper.docx")
theme = doc.send(:theme)
xml_output = theme.to_xml(encoding: "UTF-8")
puts xml_output[0..100]
# => <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
'
```

## Round-Trip Test Results

With this fix, the `standalone="yes"` attribute is now preserved during round-trip:

| File | Before | After |
|------|--------|-------|
| `[Content_Types].xml` | `standalone="yes"` missing | Preserved ✓ |
| `_rels/.rels` | `standalone="yes"` missing | Preserved ✓ |
| `word/_rels/document.xml.rels` | `standalone="yes"` missing | Preserved ✓ |
| `word/theme/_rels/theme1.xml.rels` | `standalone="yes"` missing | Preserved ✓ |
| `word/theme/theme1.xml` | `standalone="yes"` missing | Preserved ✓ |
| `docProps/app.xml` | `standalone="yes"` missing | Preserved ✓ |

## Remaining Formatting Differences

The round-trip tests still show 6 failures due to **pretty-printing differences**:

- Original: Minified XML (all on one line)
- Output: Pretty-printed XML (with newlines and indentation)

The **content is semantically equivalent** - only formatting differs. This is not a bug but a serialization style difference. The Canon XML comparison flags these as failures because it does line-by-line diff, not semantic-only comparison.

Options to address:
1. **Accept formatting differences** - Content is correct, formatting is a style choice
2. **Add `pretty: false` option** - Produce compact output, but won't match minified exactly
3. **Adjust test expectations** - Use semantic-only comparison that ignores whitespace

For OOXML documents, both minified and pretty-printed forms are valid. Word correctly reads both.
