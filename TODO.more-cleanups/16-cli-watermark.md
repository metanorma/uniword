# 16: CLI `watermark` — add/remove text and image watermarks

**Priority:** P3
**Effort:** Small (~2 hours)
**Files:**
- `lib/uniword/cli.rb` (add `watermark` command)
- `lib/uniword/document/watermark.rb` (new)

## Use Case

Legal professionals mark drafts as "CONFIDENTIAL" or "DRAFT". Organizations
brand documents with logos. Currently requires Word or manual OOXML editing.

## Proposed CLI Syntax

```bash
# Add text watermark
uniword watermark add report.docx output.docx --text "DRAFT"

# Customize watermark appearance
uniword watermark add report.docx output.docx --text "CONFIDENTIAL" \
  --font "Arial" --size 72 --color "FF0000" --opacity 25 --diagonal

# Add image watermark
uniword watermark add report.docx output.docx --image logo.png

# Remove watermark
uniword watermark remove report.docx output.docx
```

## Implementation

### Watermark Handler

OOXML text watermarks are VML shapes in the header with specific wordprocessingml
markup. They live in `word/header1.xml` (or similar header parts).

```ruby
module Uniword
  class Document
    class Watermark
      def initialize(document)
        @document = document
      end

      def add_text(text, font: "Calibri", size: 48, color: "808080",
                   opacity: 25, diagonal: true)
        # Create VML shape for watermark in default header
        # Shape type: "Word.Picture" or text-based shape
        # Semi-transparent, centered, behind text
      end

      def add_image(image_path, width: nil, height: nil)
        # Add image watermark to header
        # Similar to text but uses relationship to image part
      end

      def remove
        # Remove watermark shapes from all headers
        # VML shapes with watermark-specific properties
      end

      def present?
        # Check if document has watermark
      end
    end
  end
end
```

### CLI Integration

```ruby
desc "watermark FILE OUTPUT", "Add or remove document watermark"
option :text, desc: "Watermark text"
option :image, desc: "Watermark image path"
option :font, desc: "Font name", default: "Calibri"
option :size, desc: "Font size", type: :numeric, default: 48
option :color, desc: "Text color (hex)", default: "808080"
option :opacity, desc: "Opacity percentage (0-100)", type: :numeric, default: 25
option :diagonal, desc: "Diagonal orientation", type: :boolean, default: true
option :remove, desc: "Remove existing watermark", type: :boolean
def watermark(input_path, output_path)
  doc = DocumentFactory.from_file(input_path)
  wm = Document::Watermark.new(doc)

  if options[:remove]
    wm.remove
    say("Watermark removed", :green)
  elsif options[:text]
    wm.add_text(options[:text], **text_options)
    say("Text watermark added: #{options[:text]}", :green)
  elsif options[:image]
    wm.add_image(options[:image])
    say("Image watermark added", :green)
  else
    say("Error: specify --text, --image, or --remove", :red)
    exit 1
  end

  doc.save(output_path)
end
```

## Key Design Decisions

1. **VML in headers**: Word stores watermarks as VML shapes in the default header.
   We need to create/modify header parts.
2. **Opacity via color**: Word doesn't have direct opacity; uses semi-transparent
   colors or VML opacity attributes.
3. **Image watermark**: requires adding image to package parts and creating a
   relationship in the header.
4. **Remove**: finds and deletes VML shapes with watermark markers.

## Verification

```bash
bundle exec rspec spec/uniword/document/watermark_spec.rb
```
