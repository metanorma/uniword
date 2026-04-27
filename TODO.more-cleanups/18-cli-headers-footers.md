# 18: CLI `headers` — manage header and footer content

**Priority:** P2
**Effort:** Small (~2 hours)
**Files:**
- `lib/uniword/cli.rb` (add `headers` subcommand)
- `lib/uniword/document/header_footer_manager.rb` (new)

## Use Case

Technical writers set consistent headers/footers across documents. Legal
professionals need different first-page headers. DevOps needs to bulk-update
copyright years in footers.

## Proposed CLI Syntax

```bash
# Show current headers/footers
uniword headers show report.docx

# Set header text
uniword headers set report.docx output.docx --header "Annual Report 2026"

# Set footer with page numbers
uniword headers set report.docx output.docx --footer "Page {PAGE} of {NUMPAGES}"

# Different first page header
uniword headers set report.docx output.docx --first-header "Cover Page" --different-first

# Odd/even pages (book-style)
uniword headers set report.docx output.docx --odd-header "Chapter Title" --even-header "Book Title" --odd-even

# Clear headers/footers
uniword headers clear report.docx output.docx

# Extract header/footer text
uniword headers extract report.docx
```

## Implementation

### Header/Footer Manager

```ruby
module Uniword
  class Document
    class HeaderFooterManager
      def initialize(document)
        @document = document
      end

      def show
        sections = @document.sections
        sections.each_with_index.map do |section, i|
          {
            section: i + 1,
            default_header: section.header&.text,
            default_footer: section.footer&.text,
            first_header: section.first_header&.text,
            first_footer: section.first_footer&.text,
          }
        end
      end

      def set(header: nil, footer: nil, first_header: nil, first_footer: nil,
              different_first: false, odd_header: nil, even_header: nil,
              odd_footer: nil, even_footer: nil, odd_even: false)
        section = @document.sections.first || @document.add_section

        section.header = build_header(header) if header
        section.footer = build_footer(footer) if footer
        section.first_header = build_header(first_header) if first_header
        section.first_footer = build_footer(first_footer) if first_footer
        section.different_first = different_first

        if odd_even
          section.odd_header = build_header(odd_header) if odd_header
          section.even_header = build_header(even_header) if even_header
          section.odd_footer = build_footer(odd_footer) if odd_footer
          section.even_footer = build_footer(even_footer) if even_footer
          section.odd_even = true
        end

        @document
      end

      def clear
        @document.sections.each do |section|
          section.header = nil
          section.footer = nil
          section.first_header = nil
          section.first_footer = nil
        end
        @document
      end

      private

      FIELD_CODES = {
        "{PAGE}" => :page_number,
        "{NUMPAGES}" => :total_pages,
        "{DATE}" => :date,
        "{FILENAME}" => :filename,
      }.freeze

      def build_header(text)
        # Parse field codes in text and create Paragraph with Runs
        # FIELD codes become FieldChar elements in OOXML
      end

      def build_footer(text)
        build_header(text) # Same structure
      end
    end
  end
end
```

### CLI Integration

```ruby
class HeadersCLI < Thor
  desc "show FILE", "Show current headers/footers"
  def show(path)
    doc = DocumentFactory.from_file(path)
    manager = Document::HeaderFooterManager.new(doc)
    info = manager.show
    info.each do |s|
      say("Section #{s[:section]}:", :cyan)
      say("  Header: #{s[:default_header] || '(none)'}")
      say("  Footer: #{s[:default_footer] || '(none)'}")
      say("  First page header: #{s[:first_header] || '(none)'}") if s[:first_header]
    end
  end

  desc "set FILE OUTPUT", "Set header/footer text"
  option :header, desc: "Default header text"
  option :footer, desc: "Default footer text"
  option :first_header, desc: "First page header text"
  option :first_footer, desc: "First page footer text"
  option :different_first, desc: "Enable different first page", type: :boolean
  option :odd_header, desc: "Odd page header"
  option :even_header, desc: "Even page header"
  option :odd_footer, desc: "Odd page footer"
  option :even_footer, desc: "Even page footer"
  option :odd_even, desc: "Enable odd/even pages", type: :boolean
  def set(path, output_path)
    doc = DocumentFactory.from_file(path)
    Document::HeaderFooterManager.new(doc).set(**manager_options)
    doc.save(output_path)
    say("Headers/footers updated: #{output_path}", :green)
  end

  desc "clear FILE OUTPUT", "Remove all headers/footers"
  def clear(path, output_path)
    doc = DocumentFactory.from_file(path)
    Document::HeaderFooterManager.new(doc).clear
    doc.save(output_path)
    say("Headers/footers cleared", :green)
  end
end
```

## Key Design Decisions

1. **Field code support**: `{PAGE}`, `{NUMPAGES}`, `{DATE}`, `{FILENAME}` are
   converted to OOXML field characters (`w:fldChar` + `w:instrText`)
2. **Section-aware**: multi-section documents have separate headers/footers
   per section
3. **First page / odd-even**: these are SectionProperties flags in OOXML
4. **Text-only API**: for complex headers with images/logos, users should use
   the Ruby API or template system

## Verification

```bash
bundle exec rspec spec/uniword/document/header_footer_manager_spec.rb
```
