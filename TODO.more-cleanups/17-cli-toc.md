# 17: CLI `toc` — generate/update table of contents

**Priority:** P3
**Effort:** Medium (~3 hours)
**Files:**
- `lib/uniword/cli.rb` (add `toc` command)
- `lib/uniword/document/toc_generator.rb` (new)

## Use Case

Technical writers need to generate or update TOC in long documents. Word does
this interactively, but CLI users need programmatic TOC generation. Essential
for automated document pipelines.

## Proposed CLI Syntax

```bash
# Generate TOC from headings
uniword toc generate report.docx output.docx

# Generate with specific heading levels
uniword toc generate report.docx output.docx --levels 1-3

# Generate with custom title
uniword toc generate report.docx output.docx --title "Contents"

# Update existing TOC (regenerate with current headings)
uniword toc update report.docx output.docx

# Show TOC preview (what would be generated)
uniword toc preview report.docx
```

## Implementation

### TOC Generator

OOXML TOC is a complex structure using `w:sdt` (structured document tag) elements
with field codes `TOC \o "1-3" \h \z \u`. The TOC entry text comes from heading
paragraphs.

```ruby
module Uniword
  class Document
    class TocGenerator
      HEADING_PATTERN = /\AHeading(\d+)\z/

      def initialize(document)
        @document = document
      end

      def generate(levels: 1..3, title: "Table of Contents", position: :beginning)
        headings = extract_headings(levels: levels)
        toc = build_toc(headings, title: title)
        insert_toc(toc, position: position)
        @document
      end

      def update
        # Find existing TOC and regenerate it
        existing = find_toc
        unless existing
          raise Error, "No existing TOC found. Use generate instead."
        end

        # Extract heading levels from existing TOC field codes
        levels = extract_toc_levels(existing)
        headings = extract_headings(levels: levels)

        replace_toc(existing, headings)
        @document
      end

      def preview(levels: 1..3)
        extract_headings(levels: levels).map do |h|
          indent = "  " * (h[:level] - 1)
          "#{indent}#{h[:text]}"
        end
      end

      private

      def extract_headings(levels:)
        @document.paragraphs.each_with_object([]) do |para, list|
          style_name = para.style_name
          next unless style_name

          if (match = style_name.match(HEADING_PATTERN))
            level = match[1].to_i
            list << { level: level, text: para.text, style: style_name } if levels.cover?(level)
          end
        end
      end

      def build_toc(headings, title:)
        # Create SDT element with TOC field code
        # Add heading entries as hyperlink paragraphs
      end

      def insert_toc(toc, position:)
        case position
        when :beginning
          @document.body.elements.unshift(toc)
        when :end
          @document.body << toc
        end
      end
    end
  end
end
```

### CLI Integration

```ruby
desc "toc FILE", "Generate or update table of contents"
option :output, desc: "Output file (defaults to in-place)"
option :generate, desc: "Generate new TOC", type: :boolean
option :update, desc: "Update existing TOC", type: :boolean
option :levels, desc: "Heading levels (e.g., 1-3)", default: "1-3"
option :title, desc: "TOC title", default: "Table of Contents"
option :preview, desc: "Preview TOC without modifying", type: :boolean
def toc(path)
  doc = DocumentFactory.from_file(path)
  generator = Document::TocGenerator.new(doc)

  if options[:preview]
    lines = generator.preview(levels: parse_levels(options[:levels]))
    say("Table of Contents:", :cyan)
    lines.each { |l| say(l) }
    return
  end

  if options[:update]
    generator.update
  else
    generator.generate(levels: parse_levels(options[:levels]), title: options[:title])
  end

  output_path = options[:output] || path
  doc.save(output_path)
  say("TOC generated: #{output_path}", :green)
end
```

## Key Design Decisions

1. **OOXML TOC structure**: use `w:sdt` with `w:sdtPr > w:docPartObj` and field
   code `TOC \o "1-3"`. Word recalculates page numbers on open.
2. **Heading detection**: match paragraph style names against `Heading1` through
   `Heading9` pattern.
3. **Update vs generate**: `update` finds existing TOC SDT and replaces entries;
   `generate` creates new TOC SDT.
4. **Preview mode**: shows heading hierarchy without modifying document.

## Verification

```bash
bundle exec rspec spec/uniword/document/toc_generator_spec.rb
```
