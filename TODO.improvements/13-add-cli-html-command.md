# 13: Add CLI `html` command for HTML import/export

**Priority:** P1
**Effort:** Small (~2 hours)
**File:** `lib/uniword/cli.rb`
**Depends on:** #09 (deduplicate HTML API)

## Problem

The Ruby API supports HTML import (`from_html`, `html_to_docx`) and the
MHTML conversion pipeline includes HTML, but there's no CLI command for it.

The `convert` command only handles `docx` ↔ `mhtml`, not `html` → `docx`.

## Proposed CLI

```bash
# HTML to DOCX
uniword html import INPUT.html OUTPUT.docx

# Or as a format option in convert
uniword convert INPUT.html OUTPUT.docx --from html --to docx
```

## Implementation

Add to `convert` command's format detection in `cli.rb`:

```ruby
desc "convert INPUT OUTPUT", "Convert document between formats"
option :from, desc: "Input format (docx/mhtml/html)", type: :string
option :to, desc: "Output format (docx/mhtml)", type: :string
def convert(input_path, output_path)
  # ... existing logic ...

  when :html
    doc = Uniword.from_html(File.read(input_path))
    doc.to_file(output_path)
end
```

Also add auto-detection by file extension: `.html` / `.htm` → `:html`.

## Verification

```bash
# Create a test HTML file and convert
echo '<html><body><h1>Hello</h1><p>World</p></body></html>' > /tmp/test.html
bundle exec ruby -I lib -e 'require "uniword"; Uniword.html_to_docx(File.read("/tmp/test.html"), "/tmp/test.docx")'

bundle exec rspec spec/uniword/cli/  # if CLI specs exist
```
