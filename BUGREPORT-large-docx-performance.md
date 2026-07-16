# Bug Report: DocumentFactory.from_file causes extreme memory/CPU usage on large DOCX

## Summary

`Uniword::DocumentFactory.from_file` on a 1.4 MB DOCX file with ~2800 table rows
consumes 3 GB+ RAM and 99% CPU for 3+ minutes without completing. The
`Lutaml::Model::Serializable` full deserialization has pathological performance
for deeply nested table structures.

## Environment

- Uniword version: 1.0.11
- Ruby: 3.4.8 (arm64-darwin23)
- Platform: macOS 14.1 (Darwin 23.1.0)
- Hardware: Apple Silicon (M-series)

## Reproduction

### File

```
TC1_P3_N008-2CD_revision_of_G18-clean.docx
Size: 1,423,304 bytes (1.4 MB)
```

Structure (from word/document.xml, 21.7 MB uncompressed):
- 8 tables
- 2,847 rows (`<w:tr>`)
- 17,019 cells (`<w:tc>`)
- 19,070 paragraphs (`<w:p>`)
- 238 subscript runs, 35 superscript runs, 14 OMML equations

### Code

```ruby
require "uniword"
require "plurimath"

doc = Uniword::DocumentFactory.from_file("TC1_P3_N008-2CD_revision_of_G18-clean.docx")
puts doc.body.tables.size
```

### Observed behavior

```
PID    %CPU   %MEM     RSS        TIME
47221  99.0   4.7      3,143,904  2:59.80
```

- **Memory**: 3.1 GB RSS (resident set size)
- **CPU**: 99% (one core fully pegged)
- **Duration**: killed after 3 minutes without producing output
- **Progress**: no output at all (the `puts` never executed)

### Expected behavior

A 1.4 MB DOCX should load in seconds with reasonable memory (< 500 MB).

## Root cause analysis

`Uniword::DocumentFactory.from_file` calls `Lutaml::Model::Serializable` to
deserialize the entire OOXML document into Ruby objects. For this document:

- 17,019 TableCell objects → each containing multiple Paragraph objects
- 19,070 Paragraph objects → each containing multiple Run objects
- Estimated 100,000+ Ruby objects created during deserialization

The `Lutaml::Model` serialization appears to have O(n^2) or worse behavior
for the deeply nested table structure (tables → rows → cells → paragraphs →
runs → text elements with properties).

## Workaround

Extract `word/document.xml` from the DOCX ZIP and parse with Nokogiri directly:

```ruby
require "zip"
require "nokogiri"

Zip::File.open("input.docx") do |zip|
  xml = zip.read("word/document.xml")
  doc = Nokogiri::XML(xml)
  tables = doc.xpath("//w:tbl", w: "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
  puts tables.size  # instant (< 5 seconds, < 200 MB)
end
```

This completes in seconds with negligible memory overhead, but bypasses
Uniword's model entirely (losing the convenience API).

## Impact

Any application that needs to read large Word documents (1000+ table rows)
with Uniword is effectively blocked. This includes:
- Terminology/vocabulary extraction from standards documents
- Table-heavy reports and specifications
- Any DOCX-to-data pipeline using Uniword's model API

## Suggested fixes

### Option A: Nokogiri-based fast path (recommended)

Provide an alternative `DocumentFactory.from_file_fast` or `DocumentRoot.parse_xml`
that uses Nokogiri for initial parsing and lazily instantiates Lutaml::Model
objects only when accessed. Most use cases only need table/paragraph/cell
traversal, not full model serialization.

### Option B: Streaming/table-chunked parser

For table-heavy documents, provide a method like `DocumentRoot.each_table_row`
that streams rows one at a time without deserializing the entire document.

### Option C: Profile and optimize Lutaml::Model

Investigate where the O(n^2) behavior occurs in Lutaml::Model's deserialization.
Likely candidates:
- `element_order` tracking for mixed content
- Repeated namespace resolution for deeply nested elements
- Array allocation for collection attributes

## Comparison with Nokogiri

Same document, same data extraction:

| Approach | Time | Memory | Completes? |
|---|---|---|---|
| `Uniword::DocumentFactory.from_file` | 3+ min | 3.1 GB | No (killed) |
| Nokogiri `XML.parse` | ~3 sec | ~200 MB | Yes |
| Nokogiri + Plurimath (for OMML) | ~5 sec | ~250 MB | Yes |

The 1000x overhead is entirely in Uniword's model deserialization layer.
