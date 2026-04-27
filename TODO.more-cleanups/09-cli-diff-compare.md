# 09: CLI `diff` — structural comparison of two DOCX files

**Priority:** P1
**Effort:** Medium (~4 hours)
**Files:**
- `lib/uniword/cli.rb` (add `diff` command)
- `lib/uniword/diff/document_differ.rb` (new)
- `lib/uniword/diff/element_diff.rb` (new)
- `lib/uniword/diff/formatter.rb` (new)

## Use Case

Legal professionals compare contract versions. QA engineers verify that
programmatic edits match expected output. Currently no CLI tool does OOXML-aware
diff — `diff` on ZIP files is useless.

## Proposed CLI Syntax

```bash
# Show structural diff of two DOCX files
uniword diff old.docx new.docx

# Show only text changes (ignore formatting)
uniword diff old.docx new.docx --text-only

# Output as JSON for programmatic consumption
uniword diff old.docx new.docx --json

# Side-by-side terminal output
uniword diff old.docx new.docx --side-by-side

# Compare specific parts
uniword diff old.docx new.docx --part styles
uniword diff old.docx new.docx --part headers
```

## Implementation

### Diff Engine

```ruby
module Uniword
  module Diff
    class DocumentDiffer
      def initialize(old_doc, new_doc, options: {})
        @old = old_doc
        @new = new_doc
        @options = options
      end

      def diff
        DiffResult.new(
          text_changes: diff_text,
          format_changes: diff_formatting,
          structure_changes: diff_structure,
          metadata_changes: diff_metadata,
          style_changes: diff_styles,
        )
      end

      private

      def diff_text
        # Compare paragraphs by position, extract text-only diff
        # Use LCS (Longest Common Subsequence) for paragraph alignment
      end

      def diff_formatting
        # Compare run properties (bold, italic, font, size, color)
        # Compare paragraph properties (alignment, spacing, indentation)
      end

      def diff_structure
        # Detect added/removed/moved paragraphs, tables, sections
      end

      def diff_metadata
        # Compare core properties, custom properties
      end

      def diff_styles
        # Compare style definitions (added, removed, modified)
      end
    end
  end
end
```

### Output Formats

```ruby
module Uniword::Diff
  class Formatter
    def terminal(result, side_by_side: false)
      # Color-coded terminal output
      # Green = added, Red = removed, Yellow = modified
    end

    def json(result)
      # Structured JSON for programmatic use
    end
  end
end
```

### CLI Integration

Add `diff` command to CLI class:

```ruby
desc "diff OLD NEW", "Compare two DOCX files"
option :text_only, desc: "Show only text changes", type: :boolean, default: false
option :json, desc: "Output as JSON", type: :boolean, default: false
option :side_by_side, desc: "Side-by-side output", type: :boolean, default: false
option :part, desc: "Compare specific part (styles/headers/content)", type: :string
def diff(old_path, new_path)
  old_doc = DocumentFactory.from_file(old_path)
  new_doc = DocumentFactory.from_file(new_path)
  differ = Diff::DocumentDiffer.new(old_doc, new_doc, options: options)
  result = differ.diff
  # ... format and output
end
```

## Key Design Decisions

1. **LCS for paragraph alignment**: paragraphs may be added/removed, so use
   longest common subsequence to align old and new paragraphs before comparing.
2. **Separate text vs formatting**: legal users often care only about text
   changes; `--text-only` mode strips formatting comparison.
3. **Part-level filtering**: `--part styles` compares only the styles.xml part.

## Verification

```bash
bundle exec rspec spec/uniword/diff/
uniword diff spec/fixtures/simple.docx spec/fixtures/modified.docx
```
