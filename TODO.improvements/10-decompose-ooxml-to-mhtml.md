# 10: Decompose OoxmlToMhtmlConverter (1394 lines)

**Priority:** P2
**Effort:** Medium (~4 hours)
**File:** `lib/uniword/transformation/ooxml_to_mhtml_converter.rb`

## Problem

`OoxmlToMhtmlConverter` is a god class at 1394 lines with 34 methods covering
5 distinct responsibilities:

| Responsibility | Methods | Lines |
|---------------|---------|-------|
| MHTML document structure | `convert`, `build_mhtml_structure` | ~100 |
| HTML body generation | `generate_html_body`, element-to-HTML | ~400 |
| Metadata extraction | `extract_title`, `extract_language`, etc. | ~150 |
| Image/CSS handling | `build_style_block`, `process_images` | ~300 |
| Element-to-HTML conversion | `convert_paragraph`, `convert_table`, etc. | ~350 |

The element-to-HTML conversion (starting ~line 1138) should be its own class.
It contains 15+ `convert_*` methods that map OOXML elements to HTML tags.

## Fix

Extract into 3 classes:

```
lib/uniword/transformation/
  ooxml_to_mhtml_converter.rb      # Coordinator (~300 lines)
  mhtml/document_builder.rb        # MHTML structure (~200 lines)
  mhtml/element_to_html.rb         # Element conversion (~400 lines)
  mhtml/style_builder.rb           # CSS/style generation (~200 lines)
```

The coordinator calls the others:

```ruby
class OoxmlToMhtmlConverter
  def convert(doc)
    html_body = ElementToHtml.new.convert(doc)
    styles = StyleBuilder.new(doc).build
    DocumentBuilder.new.build(html_body, styles, metadata)
  end
end
```

Keep the public API identical (`OoxmlToMhtmlConverter.convert(document)`).

## Verification

```bash
bundle exec rspec spec/transformation/
bundle exec rspec spec/integration/mhtml*
```
